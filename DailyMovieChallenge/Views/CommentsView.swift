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
                ProgressView(String(localized: "comments.loading"))
                    .padding(.top)
            } else if viewModel.comments.isEmpty {
                Text(String(localized: "comments.no_comments"))
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
                TextField(String(localized: "comments.add_placeholder"), text: $viewModel.newCommentText, axis: .vertical)
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
                        Text(String(localized: "comments.send"))
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
                Text(String(localized: "comments.back_to_home"))
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
        .navigationTitle(String(localized: "comments.navigation_title"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadComments(challengeId: challengeId)
            if viewModel.error != nil {
                showError = true
            }
        }
        .alert(String(localized: "comments.unable_to_save"), isPresented: $showError, actions: {
            Button(String(localized: "settings.ok"), role: .cancel) {}
        }, message: {
            Text(viewModel.error?.localizedDescription ?? String(localized: "comments.try_again"))
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
                        TextField(String(localized: "comments.edit_placeholder"), text: $editText, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...4)
                        
                        HStack {
                            Button(String(localized: "comments.cancel")) {
                                isEditing = false
                                editText = comment.text
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Button(String(localized: "comments.save")) {
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
                                Text(String(localized: "comments.edited"))
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
                                comment.isLikedByCurrentUser ? String(localized: "comments.unlike") : String(localized: "comments.like"),
                                systemImage: comment.isLikedByCurrentUser ? "heart.fill" : "heart"
                            )
                        }
                        
                        if isOwnComment {
                            Button {
                                editText = comment.text
                                isEditing = true
                            } label: {
                                Label(String(localized: "comments.edit"), systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                showDeleteAlert = true
                            } label: {
                                Label(String(localized: "comments.delete"), systemImage: "trash")
                            }
                        } else {
                            Button(role: .destructive) {
                                showReportAlert = true
                            } label: {
                                Label(String(localized: "comments.report"), systemImage: "flag")
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
        .alert(String(localized: "comments.delete_title"), isPresented: $showDeleteAlert) {
            Button(String(localized: "comments.cancel"), role: .cancel) {}
            Button(String(localized: "comments.delete"), role: .destructive) {
                onDelete()
            }
        } message: {
            Text(String(localized: "comments.delete_confirm"))
        }
        .alert(String(localized: "comments.report_title"), isPresented: $showReportAlert) {
            Button(String(localized: "comments.cancel"), role: .cancel) {}
            Button(String(localized: "comments.report"), role: .destructive) {
                onReport()
            }
        } message: {
            Text(String(localized: "comments.report_confirm"))
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
