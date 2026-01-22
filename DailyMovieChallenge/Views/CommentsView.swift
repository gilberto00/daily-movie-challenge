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
                    CommentRowView(
                        comment: comment,
                        isOwnComment: viewModel.isOwnComment(comment),
                        onLike: {
                            Task {
                                await viewModel.toggleLike(commentId: comment.id)
                            }
                        },
                        onEdit: { newText in
                            Task {
                                await viewModel.editComment(commentId: comment.id, newText: newText)
                            }
                        },
                        onDelete: {
                            Task {
                                await viewModel.deleteComment(commentId: comment.id)
                            }
                        },
                        onReport: {
                            Task {
                                await viewModel.reportComment(commentId: comment.id)
                            }
                        }
                    )
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

// View separada para cada item de comentário
struct CommentRowView: View {
    let comment: Comment
    let isOwnComment: Bool
    let onLike: () -> Void
    let onEdit: (String) -> Void
    let onDelete: () -> Void
    let onReport: () -> Void
    
    @State private var isEditing = false
    @State private var editText = ""
    @State private var showDeleteAlert = false
    @State private var showReportAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                // Conteúdo do comentário
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Edit comment", text: $editText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...4)
                        
                        HStack {
                            Button("Cancel") {
                                isEditing = false
                                editText = comment.text
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button("Save") {
                                onEdit(editText)
                                isEditing = false
                            }
                            .font(.caption)
                            .foregroundColor(.blue)
                            .disabled(editText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    } else {
                        Text(comment.text)
                            .font(.body)
                        
                        HStack(spacing: 8) {
                            Text(comment.createdAt.relativeString())
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if comment.editedAt != nil {
                                Text("(edited)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Botões de ação
                if !isEditing {
                    Menu {
                        // Like/Unlike
                        Button {
                            onLike()
                        } label: {
                            Label(
                                comment.isLikedByCurrentUser ? "Unlike" : "Like",
                                systemImage: comment.isLikedByCurrentUser ? "heart.fill" : "heart"
                            )
                        }
                        
                        if isOwnComment {
                            // Editar (apenas próprio)
                            Button {
                                editText = comment.text
                                isEditing = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            // Excluir (apenas próprio)
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        } else {
                            // Report (apenas de outros)
                            Button(role: .destructive) {
                                showReportAlert = true
                            } label: {
                                Label("Report", systemImage: "flag")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                }
            }
            
            // Botão de like e contador
            if !isEditing {
                Button {
                    onLike()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: comment.isLikedByCurrentUser ? "heart.fill" : "heart")
                            .foregroundColor(comment.isLikedByCurrentUser ? .red : .secondary)
                            .font(.caption)
                        
                        if comment.likesCount > 0 {
                            Text("\(comment.likesCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .alert("Delete Comment", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("Are you sure you want to delete this comment?")
        }
        .alert("Report Comment", isPresented: $showReportAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Report", role: .destructive) {
                onReport()
            }
        } message: {
            Text("Are you sure you want to report this comment?")
        }
        .onAppear {
            editText = comment.text
        }
    }
}

#Preview {
    NavigationStack {
        CommentsView(challengeId: "2026-01-19", onBackToHome: {})
    }
}
