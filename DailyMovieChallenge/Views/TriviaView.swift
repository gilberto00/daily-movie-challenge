//
//  TriviaView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

struct TriviaView: View {
    let challenge: DailyChallenge
    let onBackToHome: () -> Void
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @StateObject private var gameViewModel = TriviaGameViewModel()
    @State private var navigateToResult = false
    @State private var result: ChallengeResult?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Movie Header with Poster
                VStack(spacing: 12) {
                    // Movie Poster (smaller version)
                    if let posterUrl = challenge.posterUrl, let url = URL(string: posterUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 120, height: 180)
                        }
                        .frame(width: 120, height: 180)
                        .cornerRadius(12)
                        .shadow(radius: 6)
                    }

                    // Movie Title
                    Text(challenge.title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.top, 8)

                Divider()
                    .padding(.vertical, 8)

                // Question
                Text(challenge.question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Answer Options - Layout adaptativo
                // Se as opções são curtas (anos, números), usar grid 2x2
                // Se são longas (textos), usar lista vertical
                let optionsAreShort = challenge.options.allSatisfy { $0.count <= 10 }
                
                if optionsAreShort && challenge.options.count == 4 {
                    // Grid 2x2 para opções curtas
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 16) {
                        ForEach(challenge.options, id: \.self) { option in
                            Button {
                                gameViewModel.selectAnswer(option)
                            } label: {
                                VStack(spacing: 8) {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                    
                                    if gameViewModel.selectedAnswer == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                            .font(.title3)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 80)
                                .padding()
                                .background(
                                    gameViewModel.selectedAnswer == option
                                        ? Color.blue.opacity(0.1)
                                        : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            gameViewModel.selectedAnswer == option
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .disabled(gameViewModel.showResult)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Lista vertical para opções longas ou quantidade diferente
                    VStack(spacing: 16) {
                        ForEach(challenge.options, id: \.self) { option in
                            Button {
                                gameViewModel.selectAnswer(option)
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                    Spacer()
                                    if gameViewModel.selectedAnswer == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    gameViewModel.selectedAnswer == option
                                        ? Color.blue.opacity(0.1)
                                        : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            gameViewModel.selectedAnswer == option
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .disabled(gameViewModel.showResult)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .safeAreaInset(edge: .bottom) {
            // Botão fixo acima da área segura - SwiftUI ajusta automaticamente o ScrollView
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    Task {
                        guard let selected = gameViewModel.selectedAnswer else { return }
                        let challengeResult = await challengeViewModel.submitAnswer(selected)
                        result = challengeResult
                        navigateToResult = true
                    }
                } label: {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            gameViewModel.selectedAnswer != nil
                                ? Color.blue
                                : Color.gray
                        )
                        .cornerRadius(12)
                }
                .disabled(gameViewModel.selectedAnswer == nil)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            }
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.05), radius: 3, y: -2)
            )
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if let posterUrl = challenge.posterUrl, let url = URL(string: posterUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 30, height: 45)
                        .cornerRadius(6)
                        .clipped()
                    }
                    Text("Challenge")
                        .font(.headline)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = result {
                ResultView(
                    result: result,
                    challengeId: challenge.id,
                    movieId: challenge.movieId
                ) {
                    // Voltar direto para Home - limpar toda a pilha
                    navigateToResult = false
                    onBackToHome()
                }
                .environmentObject(challengeViewModel)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TriviaView(
            challenge: DailyChallenge(
                id: "2026-01-19",
                movieId: 27205,
                title: "Inception",
                posterUrl: nil,
                question: "In which year was this movie released?",
                options: ["2008", "2010", "2012", "2014"],
                correctAnswer: "2010",
                curiosity: "The rotating hallway scene was filmed using a real rotating set.",
                questionType: "year",
                isExtra: false
            ),
            onBackToHome: {}
        )
        .environmentObject(DailyChallengeViewModel())
    }
}
