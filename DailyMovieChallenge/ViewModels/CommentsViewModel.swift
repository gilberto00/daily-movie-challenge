//
//  CommentsViewModel.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class CommentsViewModel: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var newCommentText: String = ""
    @Published var isSubmitting: Bool = false

    private let firestoreService = FirestoreService.shared
    
    enum CommentsError: LocalizedError {
        case notAuthenticated
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "You must be authenticated to comment."
            }
        }
    }

    func loadComments(challengeId: String) async {
        isLoading = true
        error = nil

        do {
            let currentUserId = AuthService.shared.getCurrentUserId()
            comments = try await firestoreService.fetchComments(challengeId: challengeId, currentUserId: currentUserId)
        } catch {
            self.error = error
        }

        isLoading = false
    }

    func submitComment(challengeId: String) async {
        let trimmed = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let userId = AuthService.shared.getCurrentUserId() else {
            self.error = CommentsError.notAuthenticated
            return
        }

        isSubmitting = true
        error = nil
        
        do {
            let created = try await firestoreService.addComment(
                challengeId: challengeId,
                userId: userId,
                text: trimmed
            )
            comments.insert(created, at: 0)
            newCommentText = ""
        } catch {
            self.error = error
        }
        
        isSubmitting = false
    }
    
    func editComment(commentId: String, newText: String) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            self.error = CommentsError.notAuthenticated
            return
        }
        
        do {
            try await firestoreService.editComment(commentId: commentId, newText: newText, userId: userId)
            
            // Atualizar comentário localmente
            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                var updatedComment = comments[index]
                updatedComment.text = newText
                updatedComment.editedAt = Date()
                comments[index] = updatedComment
            }
        } catch {
            self.error = error
        }
    }
    
    func deleteComment(commentId: String) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            self.error = CommentsError.notAuthenticated
            return
        }
        
        do {
            try await firestoreService.deleteComment(commentId: commentId, userId: userId)
            
            // Remover comentário localmente
            comments.removeAll { $0.id == commentId }
        } catch {
            self.error = error
        }
    }
    
    func toggleLike(commentId: String) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            self.error = CommentsError.notAuthenticated
            return
        }
        
        do {
            let isLiked = try await firestoreService.toggleLikeComment(commentId: commentId, userId: userId)
            
            // Atualizar comentário localmente
            if let index = comments.firstIndex(where: { $0.id == commentId }) {
                var updatedComment = comments[index]
                updatedComment.isLikedByCurrentUser = isLiked
                updatedComment.likesCount += isLiked ? 1 : -1
                comments[index] = updatedComment
            }
        } catch {
            self.error = error
        }
    }
    
    func reportComment(commentId: String) async {
        guard let userId = AuthService.shared.getCurrentUserId() else {
            self.error = CommentsError.notAuthenticated
            return
        }
        
        do {
            try await firestoreService.reportComment(commentId: commentId, userId: userId)
            
            // Remover comentário localmente (comentários reportados não são exibidos)
            comments.removeAll { $0.id == commentId }
        } catch {
            self.error = error
        }
    }
    
    func isOwnComment(_ comment: Comment) -> Bool {
        guard let currentUserId = AuthService.shared.getCurrentUserId() else {
            return false
        }
        return comment.userId == currentUserId
    }
}
