//
//  Comment.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation

struct Comment: Identifiable, Codable, Equatable {
    let id: String
    let challengeId: String
    let userId: String
    var text: String // Mutable for editing
    let createdAt: Date
    var editedAt: Date? // Timestamp when edited
    var likesCount: Int // Number of likes
    var isLikedByCurrentUser: Bool // If current user liked this comment
    var isReported: Bool // If comment was reported
    
    static func == (lhs: Comment, rhs: Comment) -> Bool {
        return lhs.id == rhs.id &&
               lhs.challengeId == rhs.challengeId &&
               lhs.userId == rhs.userId &&
               lhs.text == rhs.text &&
               lhs.likesCount == rhs.likesCount &&
               lhs.isLikedByCurrentUser == rhs.isLikedByCurrentUser
    }
}
