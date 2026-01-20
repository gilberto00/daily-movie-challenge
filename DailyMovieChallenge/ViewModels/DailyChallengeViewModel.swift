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
        print("🔄 [DailyChallengeViewModel] loadDailyChallenge() called")
        isLoading = true
        error = nil
        
        do {
            print("📡 [DailyChallengeViewModel] Fetching challenge...")
            challenge = try await challengeService.fetchDailyChallenge()
            print("✅ [DailyChallengeViewModel] Challenge loaded: \(challenge?.title ?? "nil")")
            
            // Carregar streak do usuário
            if let userId = AuthService.shared.getCurrentUserId() {
                print("👤 [DailyChallengeViewModel] Loading streak for user: \(userId)")
                do {
                    userStreak = try await firestoreService.getUserStreak(userId: userId)
                    print("✅ [DailyChallengeViewModel] Streak loaded: \(userStreak)")
                } catch let streakError {
                    print("⚠️ [DailyChallengeViewModel] Error loading streak: \(streakError.localizedDescription)")
                    // Não bloquear se falhar carregar streak
                    userStreak = 0
                }
            } else {
                print("⚠️ [DailyChallengeViewModel] No user ID available for streak")
            }
        } catch let challengeError {
            print("❌ [DailyChallengeViewModel] Error loading challenge: \(challengeError.localizedDescription)")
            self.error = challengeError
        }
        
        isLoading = false
        print("✅ [DailyChallengeViewModel] loadDailyChallenge() completed")
    }
    
    func submitAnswer(_ answer: String) async -> ChallengeResult {
        guard let challenge = challenge else {
            return ChallengeResult(isCorrect: false, correctAnswer: "", curiosity: "")
        }
        
        let isCorrect = answer == challenge.correctAnswer
        
        // Atualizar streak se correto
        if isCorrect, let userId = AuthService.shared.getCurrentUserId() {
            let newStreak = userStreak + 1
            do {
                try await firestoreService.updateUserStreak(userId: userId, streak: newStreak)
                userStreak = newStreak
            } catch {
                // Log error, mas não bloquear o fluxo
                print("Error updating streak: \(error)")
            }
        } else if !isCorrect, let userId = AuthService.shared.getCurrentUserId() {
            // Zerar streak se errado
            do {
                try await firestoreService.updateUserStreak(userId: userId, streak: 0)
                userStreak = 0
            } catch {
                print("Error updating streak: \(error)")
            }
        }
        
        return ChallengeResult(
            isCorrect: isCorrect,
            correctAnswer: challenge.correctAnswer,
            curiosity: challenge.curiosity
        )
    }
}
