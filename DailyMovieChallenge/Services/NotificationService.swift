//
//  NotificationService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation
import UserNotifications
import FirebaseMessaging

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
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
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
        
        // Salvar token no Firestore
        if let userId = AuthService.shared.getCurrentUserId() {
            do {
                try await firestoreService.saveFCMToken(userId: userId, token: token)
                print("✅ [NotificationService] FCM token saved to Firestore")
            } catch {
                print("⚠️ [NotificationService] Error saving FCM token: \(error)")
            }
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
