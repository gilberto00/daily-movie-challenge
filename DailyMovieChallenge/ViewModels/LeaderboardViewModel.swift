//
//  LeaderboardViewModel.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class LeaderboardViewModel: ObservableObject {
    @Published var entries: [LeaderboardEntry] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    @Published var currentUserRank: Int = 0
    @Published var currentUserEntry: LeaderboardEntry?
    
    private let firestoreService = FirestoreService.shared
    
    func loadLeaderboard() async {
        isLoading = true
        error = nil
        
        do {
            entries = try await firestoreService.fetchLeaderboard(limit: 100)
            
            // Buscar rank do usuário atual
            if let userId = AuthService.shared.getCurrentUserId() {
                currentUserRank = try await firestoreService.getUserRank(userId: userId)
                currentUserEntry = entries.first { $0.id == userId }
                
                // Se o usuário não está no top 100, buscar entrada completa
                if currentUserEntry == nil {
                    let userDoc = try await Firestore.firestore()
                        .collection("users")
                        .document(userId)
                        .getDocument()
                    
                    if let data = userDoc.data(),
                       let streak = data["streak"] as? Int,
                       let totalChallenges = data["totalChallenges"] as? Int,
                       let correctAnswers = data["correctAnswers"] as? Int,
                       let totalAnswers = data["totalAnswers"] as? Int,
                       let score = data["score"] as? Int {
                        let accuracyRate = totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) * 100.0 : 0.0
                        let badges = (data["badges"] as? [String]) ?? []
                        
                        currentUserEntry = LeaderboardEntry(
                            id: userId,
                            username: nil,
                            score: score,
                            streak: streak,
                            totalChallenges: totalChallenges,
                            accuracyRate: accuracyRate,
                            badges: badges,
                            rank: currentUserRank
                        )
                    }
                }
            }
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
