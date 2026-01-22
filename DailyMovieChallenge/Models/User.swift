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
    var totalChallenges: Int // Total de desafios completados
    var correctAnswers: Int // Total de respostas corretas
    var totalAnswers: Int // Total de respostas (para calcular taxa de acerto)
    var score: Int // Pontuação calculada
    var badges: [String] // Lista de badges conquistados
    var lastChallengeDate: Date? // Data do último desafio completado
    
    var accuracyRate: Double {
        guard totalAnswers > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalAnswers) * 100.0
    }
}

// Modelo para Leaderboard
struct LeaderboardEntry: Identifiable, Codable {
    let id: String // userId
    let username: String? // Opcional, se tiver username
    let score: Int
    let streak: Int
    let totalChallenges: Int
    let accuracyRate: Double
    let badges: [String]
    var rank: Int? // Posição no ranking
}

// Modelo para Configurações de Notificações
struct NotificationSettings: Codable {
    var dailyChallenge: Bool = true
    var streakReminder: Bool = true
    var achievements: Bool = true
    var comments: Bool = false
}
