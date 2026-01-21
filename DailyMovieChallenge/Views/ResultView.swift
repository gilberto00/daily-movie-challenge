//
//  ResultView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

struct ResultView: View {
    let result: ChallengeResult
    let challengeId: String
    @Environment(\.dismiss) var dismiss
    @State private var showCommentsSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Result Icon
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(result.isCorrect ? .green : .red)
                
                // Result Message
                Text(result.isCorrect ? "Correct!" : "Wrong!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(result.isCorrect ? .green : .red)
                
                // Correct Answer (if wrong)
                if !result.isCorrect {
                    VStack(spacing: 8) {
                        Text("Correct Answer:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(result.correctAnswer)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Curiosity
                VStack(alignment: .leading, spacing: 8) {
                    Text("Did you know?")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(result.curiosity)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                // View Comments Button (Placeholder)
                Button {
                    showCommentsSheet = true
                } label: {
                    Text("View Comments")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // Back to Home Button
                Button {
                    dismiss()
                } label: {
                    Text("Back to Home")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCommentsSheet) {
            NavigationStack {
                CommentsView(challengeId: challengeId) {
                    showCommentsSheet = false
                    dismiss()
                }
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(
            result: ChallengeResult(
                isCorrect: true,
                correctAnswer: "2010",
                curiosity: "The rotating hallway scene was filmed using a real rotating set."
            ),
            challengeId: "2026-01-19"
        )
    }
}
