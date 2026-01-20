//
//  ContentView.swift
//  DailyMovieChallenge
//
//  Created by Gilberto Rosa on 2026-01-19.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var challengeViewModel = DailyChallengeViewModel()
    
    var body: some View {
        NavigationStack {
            if authViewModel.isLoading {
                ProgressView("Authenticating...")
                    .onAppear {
                        print("🔄 [ContentView] Showing authentication loading")
                    }
            } else if authViewModel.isAuthenticated {
                HomeView()
                    .environmentObject(challengeViewModel)
                    .task {
                        print("🔄 [ContentView] Task started - loading challenge")
                        await challengeViewModel.loadDailyChallenge()
                    }
            } else {
                VStack(spacing: 12) {
                    Text("Error: Could not authenticate")
                        .font(.headline)
                    
                    if let error = authViewModel.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        #if DEBUG
                        if let nsError = error as NSError? {
                            Text("Error Code: \(nsError.code)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        #endif
                    }
                    
                    Button("Retry Authentication") {
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
    ContentView()
        .environmentObject(AuthViewModel())
}
