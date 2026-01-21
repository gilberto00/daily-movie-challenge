//
//  Comment.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation

struct Comment: Identifiable, Codable {
    let id: String
    let challengeId: String
    let userId: String
    let text: String
    let createdAt: Date
}
