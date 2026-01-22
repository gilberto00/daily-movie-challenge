//
//  DailyMovieChallengeApp.swift
//  DailyMovieChallenge
//
//  Created by Gilberto Rosa on 2026-01-19.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@main
struct DailyMovieChallengeApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        print("🚀 [DailyMovieChallengeApp] App initializing...")
        FirebaseApp.configure()
        print("✅ [DailyMovieChallengeApp] Firebase configured successfully")
        
        // Verificar se GoogleService-Info.plist foi carregado
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            print("✅ [DailyMovieChallengeApp] GoogleService-Info.plist found at: \(path)")
        } else {
            print("⚠️ [DailyMovieChallengeApp] WARNING: GoogleService-Info.plist not found!")
        }
        
        // Setup FCM
        NotificationService.shared.setupFCM()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .task {
                    print("🔄 [DailyMovieChallengeApp] App task started - authenticating...")
                    await authViewModel.authenticate()
                    
                    // Solicitar permissão de notificações após autenticação
                    if authViewModel.isAuthenticated {
                        _ = await NotificationService.shared.requestAuthorization()
                    }
                }
                .onAppear {
                    print("✅ [DailyMovieChallengeApp] App appeared")
                }
        }
    }
}
