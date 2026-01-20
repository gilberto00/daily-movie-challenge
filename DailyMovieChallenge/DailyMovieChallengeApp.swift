//
//  DailyMovieChallengeApp.swift
//  DailyMovieChallenge
//
//  Created by Gilberto Rosa on 2026-01-19.
//

import SwiftUI
import FirebaseCore

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
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .task {
                    print("🔄 [DailyMovieChallengeApp] App task started - authenticating...")
                    await authViewModel.authenticate()
                }
                .onAppear {
                    print("✅ [DailyMovieChallengeApp] App appeared")
                }
        }
    }
}
