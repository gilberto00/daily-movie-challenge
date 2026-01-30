//
//  FirestoreService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func createUser(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        
        do {
            let document = try await userRef.getDocument()
            
            if !document.exists {
                try await userRef.setData([
                    "createdAt": FieldValue.serverTimestamp(),
                    "streak": 0,
                    "totalChallenges": 0,
                    "correctAnswers": 0,
                    "totalAnswers": 0,
                    "score": 0,
                    "badges": []
                ])
            }
        } catch {
            throw error
        }
    }
    
    func updateUserStreak(userId: String, streak: Int) async throws {
        try await db.collection("users").document(userId).updateData([
            "streak": streak
        ])
    }
    
    /// Atualiza o nome/apelido do usuário no ranking (exibido no leaderboard).
    func updateUserDisplayName(userId: String, displayName: String) async throws {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        try await db.collection("users").document(userId).updateData([
            "displayName": trimmed
        ])
    }
    
    func getUserStreak(userId: String) async throws -> Int {
        let document = try await db.collection("users").document(userId).getDocument()
        
        guard let data = document.data(),
              let streak = data["streak"] as? Int else {
            return 0
        }
        
        return streak
    }

    func fetchComments(challengeId: String, currentUserId: String?) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .whereField("challengeId", isEqualTo: challengeId)
            .whereField("isReported", isEqualTo: false)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        // Capturar db antes do closure para evitar problemas de actor isolation
        let firestore = db
        
        return try await withThrowingTaskGroup(of: Comment?.self) { group in
            var comments: [Comment] = []
            
            for document in snapshot.documents {
                group.addTask {
                    let data = document.data()
                    guard
                        let userId = data["userId"] as? String,
                        let text = data["text"] as? String
                    else {
                        return nil
                    }

                    let timestamp = data["createdAt"] as? Timestamp
                    let createdAt = timestamp?.dateValue() ?? Date()
                    
                    let editedTimestamp = data["editedAt"] as? Timestamp
                    let editedAt = editedTimestamp?.dateValue()
                    
                    let likesCount = (data["likesCount"] as? Int) ?? 0
                    
                    var isLikedByCurrentUser = false
                    if let currentUserId = currentUserId {
                        let likeRef = firestore.collection("commentLikes")
                            .document("\(document.documentID)_\(currentUserId)")
                        let likeDoc = try? await likeRef.getDocument()
                        isLikedByCurrentUser = likeDoc?.exists ?? false
                    }

                    return Comment(
                        id: document.documentID,
                        challengeId: challengeId,
                        userId: userId,
                        text: text,
                        createdAt: createdAt,
                        editedAt: editedAt,
                        likesCount: likesCount,
                        isLikedByCurrentUser: isLikedByCurrentUser,
                        isReported: (data["isReported"] as? Bool) ?? false
                    )
                }
            }
            
            for try await comment in group {
                if let comment = comment {
                    comments.append(comment)
                }
            }
            
            return comments.sorted { $0.createdAt > $1.createdAt }
        }
    }

    func addComment(challengeId: String, userId: String, text: String) async throws -> Comment {
        let docRef = db.collection("comments").document()
        let data: [String: Any] = [
            "challengeId": challengeId,
            "userId": userId,
            "text": text,
            "createdAt": FieldValue.serverTimestamp(),
            "likesCount": 0,
            "isReported": false
        ]

        try await docRef.setData(data)
        let saved = try await docRef.getDocument()
        let savedData = saved.data()
        let timestamp = savedData?["createdAt"] as? Timestamp
        let createdAt = timestamp?.dateValue() ?? Date()

        return Comment(
            id: docRef.documentID,
            challengeId: challengeId,
            userId: userId,
            text: text,
            createdAt: createdAt,
            editedAt: nil,
            likesCount: 0,
            isLikedByCurrentUser: false,
            isReported: false
        )
    }
    
    // MARK: - Comment Actions
    
    func editComment(commentId: String, newText: String, userId: String) async throws {
        let commentRef = db.collection("comments").document(commentId)
        
        // Verificar se o comentário pertence ao usuário
        let commentDoc = try await commentRef.getDocument()
        guard let data = commentDoc.data(),
              let commentUserId = data["userId"] as? String,
              commentUserId == userId else {
            throw NSError(domain: "FirestoreService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only edit your own comments"])
        }
        
        try await commentRef.updateData([
            "text": newText,
            "editedAt": FieldValue.serverTimestamp()
        ])
    }
    
    func deleteComment(commentId: String, userId: String) async throws {
        let commentRef = db.collection("comments").document(commentId)
        
        // Verificar se o comentário pertence ao usuário
        let commentDoc = try await commentRef.getDocument()
        guard let data = commentDoc.data(),
              let commentUserId = data["userId"] as? String,
              commentUserId == userId else {
            throw NSError(domain: "FirestoreService", code: 403, userInfo: [NSLocalizedDescriptionKey: "You can only delete your own comments"])
        }
        
        // Deletar likes associados
        let likesSnapshot = try await db.collection("commentLikes")
            .whereField("commentId", isEqualTo: commentId)
            .getDocuments()
        
        for likeDoc in likesSnapshot.documents {
            try await likeDoc.reference.delete()
        }
        
        // Deletar comentário
        try await commentRef.delete()
    }
    
    func toggleLikeComment(commentId: String, userId: String) async throws -> Bool {
        let likeRef = db.collection("commentLikes").document("\(commentId)_\(userId)")
        let commentRef = db.collection("comments").document(commentId)
        
        let likeDoc = try await likeRef.getDocument()
        let isLiked = likeDoc.exists
        
        if isLiked {
            // Remover like
            try await likeRef.delete()
            
            // Decrementar contador
            try await commentRef.updateData([
                "likesCount": FieldValue.increment(Int64(-1))
            ])
            
            return false
        } else {
            // Adicionar like
            try await likeRef.setData([
                "commentId": commentId,
                "userId": userId,
                "createdAt": FieldValue.serverTimestamp()
            ])
            
            // Incrementar contador
            try await commentRef.updateData([
                "likesCount": FieldValue.increment(Int64(1))
            ])
            
            return true
        }
    }
    
    func reportComment(commentId: String, userId: String) async throws {
        let commentRef = db.collection("comments").document(commentId)
        
        // Marcar como reportado
        try await commentRef.updateData([
            "isReported": true,
            "reportedBy": userId,
            "reportedAt": FieldValue.serverTimestamp()
        ])
    }
    
    func getCommentsCount(challengeId: String) async throws -> Int {
        let snapshot = try await db.collection("comments")
            .whereField("challengeId", isEqualTo: challengeId)
            .whereField("isReported", isEqualTo: false)
            .count
            .getAggregation(source: .server)
        
        return Int(truncating: snapshot.count)
    }
    
    // MARK: - User Statistics & Leaderboard
    
    /// Atualiza estatísticas. Se for conclusão do desafio do dia, calcula e atualiza streak (uma vez por dia).
    /// - Returns: Novo valor da streak quando isDailyChallengeCompletion é true; nil caso contrário.
    func updateUserStats(
        userId: String,
        isCorrect: Bool,
        isDailyChallengeCompletion: Bool = false,
        challengeDate: String? = nil
    ) async throws -> Int? {
        let userRef = db.collection("users").document(userId)
        
        // Buscar dados atuais
        let userDoc = try await userRef.getDocument()
        
        // Se o documento não existe, criar primeiro
        if !userDoc.exists {
            let initialStreak = (isDailyChallengeCompletion && isCorrect && challengeDate != nil) ? 1 : 0
            try await userRef.setData([
                "createdAt": FieldValue.serverTimestamp(),
                "streak": initialStreak,
                "totalChallenges": 1,
                "correctAnswers": isCorrect ? 1 : 0,
                "totalAnswers": 1,
                "score": isCorrect ? 11 : 1,
                "badges": [],
                "lastChallengeDate": FieldValue.serverTimestamp()
            ])
            print("✅ [FirestoreService] User created with initial stats, streak: \(initialStreak)")
            return isDailyChallengeCompletion ? initialStreak : nil
        }
        
        guard let data = userDoc.data() else {
            print("⚠️ [FirestoreService] User document exists but has no data")
            return nil
        }
        
        let totalChallenges = (data["totalChallenges"] as? Int) ?? 0
        let correctAnswers = (data["correctAnswers"] as? Int) ?? 0
        let totalAnswers = (data["totalAnswers"] as? Int) ?? 0
        var streak = (data["streak"] as? Int) ?? 0
        
        // Streak só muda quando é conclusão do desafio do dia (uma vez por dia)
        if isDailyChallengeCompletion, let todayStr = challengeDate {
            let lastTimestamp = data["lastChallengeDate"] as? Timestamp
            let lastStr = lastTimestamp.map { Self.dateToYYYYMMDD($0.dateValue()) } ?? ""
            let yesterdayStr = Self.yesterdayString(from: todayStr)
            
            if lastStr == todayStr {
                // Já completou hoje: mantém streak (não zera se errar de novo)
            } else if isCorrect {
                if lastStr == yesterdayStr {
                    streak = streak + 1
                } else {
                    // Perdeu um ou mais dias, ou primeiro dia
                    streak = 1
                }
            } else {
                streak = 0
            }
            print("📊 [FirestoreService] Daily completion - today: \(todayStr), last: \(lastStr), newStreak: \(streak)")
        }
        
        let newTotalChallenges = totalChallenges + 1
        let newCorrectAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        let newTotalAnswers = totalAnswers + 1
        let accuracyRate = newTotalAnswers > 0 ? Double(newCorrectAnswers) / Double(newTotalAnswers) * 100.0 : 0.0
        let score = Int(Double(streak) * 10.0 + accuracyRate + Double(newTotalChallenges))
        
        print("📊 [FirestoreService] Updating stats - Score: \(score), Streak: \(streak), Accuracy: \(String(format: "%.1f", accuracyRate))%")
        
        var updatePayload: [String: Any] = [
            "totalChallenges": newTotalChallenges,
            "correctAnswers": newCorrectAnswers,
            "totalAnswers": newTotalAnswers,
            "score": score,
            "lastChallengeDate": FieldValue.serverTimestamp()
        ]
        if isDailyChallengeCompletion {
            updatePayload["streak"] = streak
        }
        try await userRef.updateData(updatePayload)
        
        print("✅ [FirestoreService] Stats updated successfully")
        try await checkAndAwardBadges(userId: userId)
        return isDailyChallengeCompletion ? streak : nil
    }
    
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone.current
        return f
    }()
    
    private static func dateToYYYYMMDD(_ date: Date) -> String {
        dateFormatter.string(from: date)
    }
    
    /// Retorna o dia anterior a uma data no formato YYYY-MM-DD
    private static func yesterdayString(from yyyyMMdd: String) -> String {
        guard let date = dateFormatter.date(from: yyyyMMdd) else { return "" }
        let cal = Calendar.current
        guard let yesterday = cal.date(byAdding: .day, value: -1, to: date) else { return "" }
        return dateFormatter.string(from: yesterday)
    }
    
    private func checkAndAwardBadges(userId: String) async throws {
        let userRef = db.collection("users").document(userId)
        let userDoc = try await userRef.getDocument()
        
        guard let data = userDoc.data() else { return }
        
        let streak = (data["streak"] as? Int) ?? 0
        let totalChallenges = (data["totalChallenges"] as? Int) ?? 0
        let correctAnswers = (data["correctAnswers"] as? Int) ?? 0
        let totalAnswers = (data["totalAnswers"] as? Int) ?? 0
        let accuracyRate = totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) * 100.0 : 0.0
        
        var currentBadges = (data["badges"] as? [String]) ?? []
        var newBadges: [String] = []
        
        // Verificar badges
        if streak >= 7 && !currentBadges.contains("streak_7") {
            newBadges.append("streak_7")
        }
        if streak >= 30 && !currentBadges.contains("streak_30") {
            newBadges.append("streak_30")
        }
        if totalChallenges >= 100 && !currentBadges.contains("challenges_100") {
            newBadges.append("challenges_100")
        }
        if accuracyRate >= 80.0 && totalAnswers >= 10 && !currentBadges.contains("accuracy_80") {
            newBadges.append("accuracy_80")
        }
        
        if !newBadges.isEmpty {
            currentBadges.append(contentsOf: newBadges)
            try await userRef.updateData([
                "badges": currentBadges
            ])
        }
    }
    
    func fetchLeaderboard(limit: Int = 100) async throws -> [LeaderboardEntry] {
        print("📊 [FirestoreService] Fetching leaderboard...")
        let snapshot = try await db.collection("users")
            .order(by: "score", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        print("✅ [FirestoreService] Found \(snapshot.documents.count) users in leaderboard")
        
        return snapshot.documents.enumerated().compactMap { index, document in
            let data = document.data()
            guard
                let streak = data["streak"] as? Int,
                let totalChallenges = data["totalChallenges"] as? Int,
                let correctAnswers = data["correctAnswers"] as? Int,
                let totalAnswers = data["totalAnswers"] as? Int,
                let score = data["score"] as? Int
            else {
                return nil
            }
            
            let accuracyRate = totalAnswers > 0 ? Double(correctAnswers) / Double(totalAnswers) * 100.0 : 0.0
            let badges = (data["badges"] as? [String]) ?? []
            let displayName = (data["displayName"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines)
            let username = displayName?.isEmpty == false ? displayName : nil
            
            return LeaderboardEntry(
                id: document.documentID,
                username: username,
                score: score,
                streak: streak,
                totalChallenges: totalChallenges,
                accuracyRate: accuracyRate,
                badges: badges,
                rank: index + 1
            )
        }
    }
    
    func getUserRank(userId: String) async throws -> Int {
        let userDoc = try await db.collection("users").document(userId).getDocument()
        guard let userData = userDoc.data(),
              let userScore = userData["score"] as? Int else {
            return 0
        }
        
        // Contar quantos usuários têm score maior
        let snapshot = try await db.collection("users")
            .whereField("score", isGreaterThan: userScore)
            .count
            .getAggregation(source: .server)
        
        let usersAhead = Int(truncating: snapshot.count)
        return usersAhead + 1
    }
    
    // MARK: - FCM Tokens
    
    func saveFCMToken(userId: String, token: String) async throws {
        let tokenRef = db.collection("fcmTokens").document(userId)
        try await tokenRef.setData([
            "token": token,
            "updatedAt": FieldValue.serverTimestamp(),
            "platform": "iOS"
        ])
    }
    
    func getFCMToken(userId: String) async throws -> String? {
        let tokenDoc = try await db.collection("fcmTokens").document(userId).getDocument()
        guard let data = tokenDoc.data(),
              let token = data["token"] as? String else {
            return nil
        }
        return token
    }
    
    // MARK: - Notification Settings
    
    func getNotificationSettings(userId: String) async throws -> NotificationSettings {
        let settingsRef = db.collection("notificationSettings").document(userId)
        let settingsDoc = try await settingsRef.getDocument()
        
        if let data = settingsDoc.data() {
            return NotificationSettings(
                dailyChallenge: (data["dailyChallenge"] as? Bool) ?? true,
                streakReminder: (data["streakReminder"] as? Bool) ?? true,
                achievements: (data["achievements"] as? Bool) ?? true,
                comments: (data["comments"] as? Bool) ?? false
            )
        }
        
        // Retornar defaults se não existir
        return NotificationSettings()
    }
    
    func updateNotificationSettings(userId: String, settings: NotificationSettings) async throws {
        let settingsRef = db.collection("notificationSettings").document(userId)
        try await settingsRef.setData([
            "dailyChallenge": settings.dailyChallenge,
            "streakReminder": settings.streakReminder,
            "achievements": settings.achievements,
            "comments": settings.comments,
            "updatedAt": FieldValue.serverTimestamp()
        ])
    }
}
