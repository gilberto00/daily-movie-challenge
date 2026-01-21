//
//  DailyChallenge.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation

struct DailyChallenge: Codable, Identifiable, Equatable {
    let id: String  // Date string (YYYY-MM-DD-HH) or custom ID for extras
    let movieId: Int
    let title: String
    let posterUrl: String?
    let question: String
    let options: [String]
    let correctAnswer: String
    let curiosity: String
    let questionType: String?
    let isExtra: Bool?
    
    // Implementação manual de Equatable para comparar todas as propriedades
    static func == (lhs: DailyChallenge, rhs: DailyChallenge) -> Bool {
        return lhs.id == rhs.id &&
               lhs.movieId == rhs.movieId &&
               lhs.title == rhs.title &&
               lhs.posterUrl == rhs.posterUrl &&
               lhs.question == rhs.question &&
               lhs.options == rhs.options &&
               lhs.correctAnswer == rhs.correctAnswer &&
               lhs.curiosity == rhs.curiosity &&
               lhs.questionType == rhs.questionType &&
               lhs.isExtra == rhs.isExtra
    }
}
