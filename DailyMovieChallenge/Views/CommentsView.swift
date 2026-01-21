//
//  CommentsView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import SwiftUI

struct CommentsView: View {
    let challengeId: String
    let onBackToHome: () -> Void
    @StateObject private var viewModel = CommentsViewModel()
    @State private var isSubmitting = false
    @State private var showError = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                ProgressView("Loading comments...")
                    .padding(.top)
            } else if viewModel.comments.isEmpty {
                Text("No comments yet. Be the first!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top)
            } else {
                List(viewModel.comments) { comment in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(comment.text)
                            .font(.body)
                        Text(Self.dateFormatter.string(from: comment.createdAt))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }

            Divider()

            HStack(spacing: 8) {
                TextField("Add a comment...", text: $viewModel.newCommentText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...3)

                Button {
                    guard !isSubmitting else { return }
                    isSubmitting = true
                    Task {
                        await viewModel.submitComment(challengeId: challengeId)
                        isSubmitting = false
                        if viewModel.error != nil {
                            showError = true
                        }
                    }
                } label: {
                    Text("Send")
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray.opacity(0.3) : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
            }
            .padding(.horizontal)
            .padding(.bottom, 12)

            Button {
                print("🔄 [CommentsView] Back to Home button pressionado")
                // Chamar o callback que fecha o sheet e volta para Home
                onBackToHome()
            } label: {
                Text("Back to Home")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .navigationTitle("Comments")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadComments(challengeId: challengeId)
            if viewModel.error != nil {
                showError = true
            }
        }
        .alert("Unable to save comment", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(viewModel.error?.localizedDescription ?? "Please try again.")
        })
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

#Preview {
    NavigationStack {
        CommentsView(challengeId: "2026-01-19", onBackToHome: {})
    }
}
