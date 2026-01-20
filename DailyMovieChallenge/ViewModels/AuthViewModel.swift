//
//  AuthViewModel.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userId: String?
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private let authService = AuthService.shared
    private let firestoreService = FirestoreService.shared
    
    func authenticate() async {
        print("🔄 [AuthViewModel] authenticate() called")
        isLoading = true
        error = nil
        
        do {
            // Autenticar anonimamente
            print("🔐 [AuthViewModel] Signing in anonymously...")
            let uid = try await authService.signInAnonymously()
            print("✅ [AuthViewModel] Anonymous auth successful. User ID: \(uid)")
            userId = uid
            isAuthenticated = true
            
            // Criar usuário no Firestore se não existir
            // Se falhar, não bloqueia a autenticação (pode ser problema de regras)
            do {
                print("📝 [AuthViewModel] Creating user in Firestore...")
                try await firestoreService.createUser(userId: uid)
                print("✅ [AuthViewModel] User created in Firestore")
            } catch let firestoreError {
                // Log erro mas não bloqueia - pode ser que o usuário já exista ou regras ainda não deployadas
                print("⚠️ [AuthViewModel] Warning: Could not create user in Firestore: \(firestoreError.localizedDescription)")
                print("⚠️ [AuthViewModel] Error type: \(type(of: firestoreError))")
            }
        } catch let authError {
            print("❌ [AuthViewModel] Authentication error: \(authError.localizedDescription)")
            print("❌ [AuthViewModel] Error type: \(type(of: authError))")
            self.error = authError
            isAuthenticated = false
        }
        
        isLoading = false
        print("✅ [AuthViewModel] authenticate() completed. isAuthenticated: \(isAuthenticated)")
    }
}
