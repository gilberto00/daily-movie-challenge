//
//  AuthService.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }
    
    func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}
