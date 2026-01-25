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
    @StateObject private var deepLinkService = DeepLinkService.shared
    @State private var navigationPath = NavigationPath()
    
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
            ContentView(navigationPath: $navigationPath)
                .environmentObject(authViewModel)
                .environmentObject(deepLinkService)
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
                .onOpenURL { url in
                    print("🔗 [DailyMovieChallengeApp] Received URL: \(url)")
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard let destination = deepLinkService.handleURL(url) else {
            print("⚠️ [DailyMovieChallengeApp] Could not handle deep link: \(url)")
            return
        }
        
        // Converte DeepLinkDestination para NavigationDestination
        let navDestination: NavigationDestination
        switch destination {
        case .home:
            // Limpar navegação e voltar para home
            navigationPath.removeLast(navigationPath.count)
            return
        case .trivia, .challenge:
            navDestination = .trivia
        case .result:
            navDestination = .result
        case .leaderboard:
            navDestination = .leaderboard
        case .settings:
            navDestination = .settings
        }
        
        // Navegar para o destino
        navigationPath.append(navDestination)
        print("✅ [DailyMovieChallengeApp] Navigating to: \(navDestination)")
    }
}
