//
//  DailyChallenge.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation

struct DailyChallenge: Codable, Identifiable {
    let id: String  // Date string (YYYY-MM-DD)
    let movieId: Int
    let title: String
    let posterUrl: String?
    let question: String
    let options: [String]
    let correctAnswer: String
    let curiosity: String
}
