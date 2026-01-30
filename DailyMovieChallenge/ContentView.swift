//
//  ContentView.swift
//  DailyMovieChallenge
//
//  Created by Gilberto Rosa on 2026-01-19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var deepLinkService: DeepLinkService
    @StateObject private var challengeViewModel = DailyChallengeViewModel()
    @State private var hasLoadedInitialChallenge = false
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            if authViewModel.isLoading {
                ProgressView(String(localized: "auth.authenticating"))
                    .onAppear {
                        print("🔄 [ContentView] Showing authentication loading")
                    }
            } else if authViewModel.isAuthenticated {
                HomeView(navigationPath: $navigationPath)
                    .environmentObject(challengeViewModel)
                    .task {
                        // Carregar desafio apenas na primeira vez
                        if !hasLoadedInitialChallenge {
                            print("🔄 [ContentView] Task started - loading initial challenge")
                            await challengeViewModel.loadDailyChallenge()
                            hasLoadedInitialChallenge = true
                        }
                    }
            } else {
                VStack(spacing: 12) {
                    Text(String(localized: "auth.error"))
                        .font(.headline)
                    
                    if let error = authViewModel.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        #if DEBUG
                        if let nsError = error as NSError? {
                            Text(String(format: String(localized: "auth.error_code"), nsError.code))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        #endif
                    }
                    
                    Button(String(localized: "auth.retry")) {
                        print("🔄 [ContentView] Retry authentication button tapped")
                        Task {
                            await authViewModel.authenticate()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .onAppear {
                    print("❌ [ContentView] Authentication failed. Error: \(authViewModel.error?.localizedDescription ?? "unknown")")
                }
            }
        }
        .onAppear {
            print("🔄 [ContentView] ContentView appeared")
            print("🔄 [ContentView] Auth status - isLoading: \(authViewModel.isLoading), isAuthenticated: \(authViewModel.isAuthenticated)")
        }
    }
}

#Preview {
    ContentView(navigationPath: .constant(NavigationPath()))
        .environmentObject(AuthViewModel())
        .environmentObject(DeepLinkService.shared)
}
