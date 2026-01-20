//
//  User.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation

struct User: Codable {
    let id: String
    let createdAt: Date
    var streak: Int
}
