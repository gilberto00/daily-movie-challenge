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
        print("📝 [FirestoreService] createUser() called for userId: \(userId)")
        let userRef = db.collection("users").document(userId)
        
        do {
            let document = try await userRef.getDocument()
            print("📊 [FirestoreService] Document exists: \(document.exists)")
            
            if !document.exists {
                print("➕ [FirestoreService] Creating new user document...")
                try await userRef.setData([
                    "createdAt": FieldValue.serverTimestamp(),
                    "streak": 0
                ])
                print("✅ [FirestoreService] User document created successfully")
            } else {
                print("ℹ️ [FirestoreService] User document already exists")
            }
        } catch let error {
            print("❌ [FirestoreService] Error creating user: \(error.localizedDescription)")
            print("❌ [FirestoreService] Error type: \(type(of: error))")
            if let nsError = error as NSError? {
                print("❌ [FirestoreService] Error domain: \(nsError.domain)")
                print("❌ [FirestoreService] Error code: \(nsError.code)")
                print("❌ [FirestoreService] Error userInfo: \(nsError.userInfo)")
            }
            throw error
        }
    }
    
    func updateUserStreak(userId: String, streak: Int) async throws {
        try await db.collection("users").document(userId).updateData([
            "streak": streak
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

    func fetchComments(challengeId: String) async throws -> [Comment] {
        let snapshot = try await db.collection("comments")
            .whereField("challengeId", isEqualTo: challengeId)
            .order(by: "createdAt", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { document in
            let data = document.data()
            guard
                let userId = data["userId"] as? String,
                let text = data["text"] as? String
            else {
                return nil
            }

            let timestamp = data["createdAt"] as? Timestamp
            let createdAt = timestamp?.dateValue() ?? Date()

            return Comment(
                id: document.documentID,
                challengeId: challengeId,
                userId: userId,
                text: text,
                createdAt: createdAt
            )
        }
    }

    func addComment(challengeId: String, userId: String, text: String) async throws -> Comment {
        let docRef = db.collection("comments").document()
        let data: [String: Any] = [
            "challengeId": challengeId,
            "userId": userId,
            "text": text,
            "createdAt": FieldValue.serverTimestamp()
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
            createdAt: createdAt
        )
    }
    
    func getCommentsCount(challengeId: String) async throws -> Int {
        let snapshot = try await db.collection("comments")
            .whereField("challengeId", isEqualTo: challengeId)
            .count
            .getAggregation(source: .server)
        
        return Int(truncating: snapshot.count)
    }
}
