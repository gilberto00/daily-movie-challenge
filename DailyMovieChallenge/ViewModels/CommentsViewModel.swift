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
            comments = try await firestoreService.fetchComments(challengeId: challengeId)
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
}
