//
//  TriviaView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

struct TriviaView: View {
    let challenge: DailyChallenge
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @StateObject private var gameViewModel = TriviaGameViewModel()
    @State private var navigateToResult = false
    @State private var result: ChallengeResult?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Question
                Text(challenge.question)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Answer Options
                VStack(spacing: 16) {
                    ForEach(challenge.options, id: \.self) { option in
                        Button {
                            gameViewModel.selectAnswer(option)
                        } label: {
                            HStack {
                                Text(option)
                                    .font(.headline)
                                    .foregroundColor(.primary)
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
                
                // Submit Button
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
            }
            .padding()
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = result {
                ResultView(result: result)
            }
        }
    }
}

#Preview {
    NavigationStack {
        TriviaView(challenge: DailyChallenge(
            id: "2026-01-19",
            movieId: 27205,
            title: "Inception",
            posterUrl: nil,
            question: "In which year was this movie released?",
            options: ["2008", "2010", "2012", "2014"],
            correctAnswer: "2010",
            curiosity: "The rotating hallway scene was filmed using a real rotating set."
        ))
        .environmentObject(DailyChallengeViewModel())
    }
}
