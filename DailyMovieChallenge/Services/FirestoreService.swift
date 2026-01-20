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
}
