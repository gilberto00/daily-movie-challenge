//
//  HomeView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @State private var navigateToTrivia = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text("Daily Movie Challenge")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // Streak Indicator
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("Streak: \(challengeViewModel.userStreak)")
                        .font(.headline)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(12)
                
                if challengeViewModel.isLoading {
                    ProgressView("Loading challenge...")
                        .padding()
                } else if let challenge = challengeViewModel.challenge {
                    // Movie Poster
                    if let posterUrl = challenge.posterUrl, let url = URL(string: posterUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 200, height: 300)
                        }
                        .frame(width: 200, height: 300)
                        .cornerRadius(12)
                        .shadow(radius: 8)
                    }
                    
                    // Movie Title
                    Text(challenge.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    // Play Button
                    Button {
                        navigateToTrivia = true
                    } label: {
                        Text("Play")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                } else if let error = challengeViewModel.error {
                    VStack(spacing: 16) {
                        Text("Error loading challenge")
                            .font(.headline)
                        
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                        
                        // Mostrar detalhes do erro para debug
                        #if DEBUG
                        if let nsError = error as NSError? {
                            Text("Code: \(nsError.code)")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Text(nsError.localizedDescription)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        #endif
                        
                        Button("Retry") {
                            print("🔄 [HomeView] Retry button tapped")
                            Task {
                                await challengeViewModel.loadDailyChallenge()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $navigateToTrivia) {
            if let challenge = challengeViewModel.challenge {
                TriviaView(
                    challenge: challenge,
                    onBackToHome: {
                        // Resetar navegação para voltar à Home
                        print("🔄 [HomeView] Voltando para Home - resetando navigateToTrivia")
                        navigateToTrivia = false
                    }
                )
                .environmentObject(challengeViewModel)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(DailyChallengeViewModel())
}
