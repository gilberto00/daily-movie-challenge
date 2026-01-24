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
    
    // Rastrear perguntas já jogadas na sessão atual (por ID único)
    private var playedQuestionIds: Set<String> = []
    // Rastrear tipos de perguntas já jogadas por filme (movieId -> [questionType])
    private var playedQuestionTypesByMovie: [Int: Set<String>] = [:]
    // Rastrear texto completo das perguntas já jogadas por filme (movieId -> Set<questionText>)
    private var playedQuestionTextsByMovie: [Int: Set<String>] = [:]
    
    private let challengeService = ChallengeService.shared
    private let firestoreService = FirestoreService.shared
    
    func loadDailyChallenge() async {
        isLoading = true
        error = nil
        
        do {
            let newChallenge = try await challengeService.fetchDailyChallenge()
            challenge = newChallenge
            
            // Registrar pergunta inicial como jogada
            if let challenge = challenge {
                markQuestionAsPlayed(challenge)
            }
            
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
        
        // Marcar pergunta como jogada antes de processar resposta
        markQuestionAsPlayed(challenge)
        
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
        
        // Verificar se todas as perguntas já foram jogadas
        if areAllQuestionsPlayed(for: movieId) {
            self.error = NSError(
                domain: "DailyChallengeViewModel",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Você já jogou todas as perguntas disponíveis para este filme! Tente um novo filme."]
            )
            isLoading = false
            return
        }
        
        // Tentar até 10 vezes para evitar perguntas duplicadas
        var attempts = 0
        let maxAttempts = 10
        var newChallenge: DailyChallenge?
        
        repeat {
            attempts += 1
            
            do {
                let fetchedChallenge = try await challengeService.fetchExtraQuestion(
                    movieId: movieId,
                    excludeTypes: excludeTypes
                )
                
                // Verificar se esta pergunta já foi jogada
                if !isQuestionAlreadyPlayed(fetchedChallenge) {
                    newChallenge = fetchedChallenge
                    break // Pergunta nova encontrada
                } else {
                    print("⚠️ [DailyChallengeViewModel] Pergunta duplicada detectada (tentativa \(attempts)/\(maxAttempts)): \(fetchedChallenge.id)")
                    // Pequeno delay para evitar requisições muito rápidas
                    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 segundos
                }
            } catch {
                // Se for o último attempt, retornar o erro
                if attempts >= maxAttempts {
                    self.error = error
                    isLoading = false
                    return
                }
            }
        } while attempts < maxAttempts
        
        if let newChallenge = newChallenge {
            challenge = newChallenge
            markQuestionAsPlayed(newChallenge)
        } else {
            // Se não conseguiu gerar pergunta nova após várias tentativas
            self.error = NSError(
                domain: "DailyChallengeViewModel",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Não foi possível gerar uma nova pergunta. Todas as perguntas disponíveis para este filme já foram jogadas. Tente um novo filme!"]
            )
        }
        
        isLoading = false
    }
    
    func loadNewMovieChallenge() async {
        isLoading = true
        error = nil
        
        do {
            let newChallenge = try await challengeService.fetchNewMovieChallenge()
            challenge = newChallenge
            
            // Registrar nova pergunta como jogada
            if let challenge = challenge {
                markQuestionAsPlayed(challenge)
            }
            
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    // MARK: - Question Tracking
    
    /// Marca uma pergunta como já jogada
    private func markQuestionAsPlayed(_ challenge: DailyChallenge) {
        // Adicionar ID único da pergunta
        playedQuestionIds.insert(challenge.id)
        
        // Adicionar tipo de pergunta para o filme específico
        if let questionType = challenge.questionType {
            if playedQuestionTypesByMovie[challenge.movieId] == nil {
                playedQuestionTypesByMovie[challenge.movieId] = Set<String>()
            }
            playedQuestionTypesByMovie[challenge.movieId]?.insert(questionType)
        }
        
        // Adicionar texto completo da pergunta para o filme específico
        if playedQuestionTextsByMovie[challenge.movieId] == nil {
            playedQuestionTextsByMovie[challenge.movieId] = Set<String>()
        }
        playedQuestionTextsByMovie[challenge.movieId]?.insert(challenge.question)
        
        print("✅ [DailyChallengeViewModel] Pergunta marcada como jogada: ID=\(challenge.id), Type=\(challenge.questionType ?? "unknown"), Question=\(challenge.question.prefix(50))...")
    }
    
    /// Verifica se uma pergunta já foi jogada
    private func isQuestionAlreadyPlayed(_ challenge: DailyChallenge) -> Bool {
        // Verificar por ID
        if playedQuestionIds.contains(challenge.id) {
            print("⚠️ [DailyChallengeViewModel] Duplicata detectada por ID: \(challenge.id)")
            return true
        }
        
        // Verificar se o texto completo da pergunta já foi jogado para este filme
        if let playedTexts = playedQuestionTextsByMovie[challenge.movieId],
           playedTexts.contains(challenge.question) {
            print("⚠️ [DailyChallengeViewModel] Duplicata detectada por texto: \(challenge.question.prefix(50))...")
            return true
        }
        
        // Verificar se todos os 5 tipos já foram jogados para este filme
        if let playedTypes = playedQuestionTypesByMovie[challenge.movieId],
           playedTypes.count >= 5 {
            // Se todos os tipos foram jogados, verificar se é do mesmo tipo que já foi jogado
            if let questionType = challenge.questionType,
               playedTypes.contains(questionType) {
                print("⚠️ [DailyChallengeViewModel] Todos os tipos já foram jogados e este tipo (\(questionType)) já foi usado")
                return true
            }
        }
        
        return false
    }
    
    /// Retorna os tipos de perguntas já jogadas para um filme específico
    func getPlayedQuestionTypes(for movieId: Int) -> [String] {
        return Array(playedQuestionTypesByMovie[movieId] ?? Set<String>())
    }
    
    /// Verifica se todas as perguntas disponíveis para um filme já foram jogadas
    func areAllQuestionsPlayed(for movieId: Int) -> Bool {
        if let playedTypes = playedQuestionTypesByMovie[movieId],
           playedTypes.count >= 5 {
            // Todos os 5 tipos foram jogados
            return true
        }
        return false
    }
    
    /// Limpa o rastreamento de perguntas (útil quando muda de filme)
    func resetQuestionTracking() {
        playedQuestionIds.removeAll()
        playedQuestionTypesByMovie.removeAll()
        playedQuestionTextsByMovie.removeAll()
        print("🔄 [DailyChallengeViewModel] Rastreamento de perguntas resetado")
    }
}
