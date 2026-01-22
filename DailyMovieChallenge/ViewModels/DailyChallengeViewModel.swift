//
//  DailyChallengeViewModel.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class DailyChallengeViewModel: ObservableObject {
    @Published var challenge: DailyChallenge?
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var userStreak: Int = 0
    
    private let challengeService = ChallengeService.shared
    private let firestoreService = FirestoreService.shared
    
    func loadDailyChallenge() async {
        isLoading = true
        error = nil
        
        do {
            challenge = try await challengeService.fetchDailyChallenge()
            
            // Carregar streak do usuário
            if let userId = AuthService.shared.getCurrentUserId() {
                do {
                    userStreak = try await firestoreService.getUserStreak(userId: userId)
                } catch {
                    // Não bloquear se falhar carregar streak
                    userStreak = 0
                }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func submitAnswer(_ answer: String) async -> ChallengeResult {
        guard let challenge = challenge else {
            return ChallengeResult(isCorrect: false, correctAnswer: "", curiosity: "")
        }
        
        let isCorrect = answer == challenge.correctAnswer
        
        // Atualizar estatísticas do usuário
        if let userId = AuthService.shared.getCurrentUserId() {
            // Calcular novo streak
            let newStreak = isCorrect ? userStreak + 1 : 0
            
            do {
                // Atualizar streak primeiro
                try await firestoreService.updateUserStreak(userId: userId, streak: newStreak)
                userStreak = newStreak
                
                // Atualizar estatísticas completas (totalChallenges, correctAnswers, score, badges)
                try await firestoreService.updateUserStats(userId: userId, isCorrect: isCorrect)
            } catch {
                // Log error, mas não bloquear o fluxo
                print("⚠️ [DailyChallengeViewModel] Error updating user stats: \(error.localizedDescription)")
            }
        }
        
        return ChallengeResult(
            isCorrect: isCorrect,
            correctAnswer: challenge.correctAnswer,
            curiosity: challenge.curiosity
        )
    }
    
    func loadExtraQuestion(movieId: Int, excludeTypes: [String]) async {
        isLoading = true
        error = nil
        
        do {
            challenge = try await challengeService.fetchExtraQuestion(movieId: movieId, excludeTypes: excludeTypes)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
    
    func loadNewMovieChallenge() async {
        isLoading = true
        error = nil
        
        do {
            let newChallenge = try await challengeService.fetchNewMovieChallenge()
            challenge = newChallenge
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
