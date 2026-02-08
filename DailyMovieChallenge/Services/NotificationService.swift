//
//  NotificationService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation
import UserNotifications
import FirebaseMessaging
import Combine
import UIKit

class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isAuthorized: Bool = false
    @Published var fcmToken: String?
    
    private let firestoreService = FirestoreService.shared
    
    private override init() {
        super.init()
    }
    
    // MARK: - Request Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            )
            
            await MainActor.run {
                self.isAuthorized = granted
            }
            
            if granted {
                print("✅ [NotificationService] Notification authorization granted")
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                print("✅ [NotificationService] Registered for remote notifications")
            } else {
                print("⚠️ [NotificationService] Notification authorization denied")
            }
            
            return granted
        } catch {
            print("❌ [NotificationService] Error requesting authorization: \(error)")
            return false
        }
    }
    
    // MARK: - FCM Token Management
    
    func setupFCM() {
        Messaging.messaging().delegate = self
        
        // Obter token atual se disponível
        Messaging.messaging().token { [weak self] token, error in
            guard let self = self else { return }
            
            if let error = error {
                print("❌ [NotificationService] Error fetching FCM token: \(error)")
                return
            }
            
            if let token = token {
                Task {
                    await self.handleFCMToken(token)
                }
            }
        }
    }
    
    private func handleFCMToken(_ token: String) async {
        await MainActor.run {
            self.fcmToken = token
        }
        
        print("✅ [NotificationService] FCM token received: \(token)")
        
        // Salvar token no Firestore
        if let userId = AuthService.shared.getCurrentUserId() {
            do {
                try await firestoreService.saveFCMToken(userId: userId, token: token)
                print("✅ [NotificationService] FCM token saved to Firestore for user: \(userId)")
                print("📋 [NotificationService] Copy this token to test notifications in Firebase Console:")
                print("   \(token)")
            } catch {
                print("⚠️ [NotificationService] Error saving FCM token: \(error)")
            }
        } else {
            print("⚠️ [NotificationService] User not authenticated, cannot save FCM token (will retry when auth completes)")
        }
    }
    
    /// Tenta salvar o token FCM novamente (ex.: após autenticação). Usado para corrigir race condition onde o token chega antes do auth.
    func saveTokenIfNeeded() async {
        var token: String?
        await MainActor.run {
            token = self.fcmToken
        }
        if token == nil {
            token = await withCheckedContinuation { continuation in
                Messaging.messaging().token { t, error in
                    if let error = error {
                        print("⚠️ [NotificationService] Error fetching token for retry: \(error)")
                    }
                    continuation.resume(returning: t)
                }
            }
        }
        let userId = AuthService.shared.getCurrentUserId()
        print("📋 [NotificationService] saveTokenIfNeeded - token: \(token != nil ? "present" : "nil"), userId: \(userId ?? "nil")")
        if let token = token {
            await handleFCMToken(token)
        } else {
            print("⚠️ [NotificationService] saveTokenIfNeeded - token nil (APNs pode não estar configurado para este app no Firebase Cloud Messaging)")
        }
    }
    
    // MARK: - Notification Settings
    
    func getNotificationSettings() async throws -> NotificationSettings {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            throw NSError(domain: "NotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        return try await firestoreService.getNotificationSettings(userId: userId)
    }
    
    func updateNotificationSettings(_ settings: NotificationSettings) async throws {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            throw NSError(domain: "NotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        try await firestoreService.updateNotificationSettings(userId: userId, settings: settings)
    }
}

// MARK: - MessagingDelegate

extension NotificationService: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else { return }
        
        Task {
            await handleFCMToken(fcmToken)
        }
    }
}
