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
                        Text(comment.createdAt.relativeString())
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
                    Task {
                        await viewModel.submitComment(challengeId: challengeId)
                        if viewModel.error != nil {
                            showError = true
                        }
                    }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    } else {
                        Text("Send")
                            .font(.headline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                    }
                }
                .frame(width: 80, height: 36)
                .background(
                    viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmitting
                        ? Color.gray.opacity(0.3)
                        : Color.blue
                )
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmitting)
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

}

#Preview {
    NavigationStack {
        CommentsView(challengeId: "2026-01-19", onBackToHome: {})
    }
}
