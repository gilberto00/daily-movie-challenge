//
//  TriviaGameViewModel.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TriviaGameViewModel: ObservableObject {
    /// Resposta interna quando o tempo esgota; nunca coincide com opções reais de trivia.
    static let timeoutSentinel = "__DMC_TIMEOUT_NO_ANSWER__"
    static let answerTimeLimitSeconds = 30

    @Published var selectedAnswer: String?
    @Published var showResult: Bool = false
    @Published var result: ChallengeResult?
    @Published private(set) var remainingSeconds: Int = TriviaGameViewModel.answerTimeLimitSeconds

    private var timerTask: Task<Void, Never>?

    func selectAnswer(_ answer: String) {
        guard !showResult else { return }
        selectedAnswer = answer
    }

    /// Bloqueia a ronda (UI + timer) e devolve `true` se esta chamada ganhou a corrida (evita duplo submit).
    func lockForSubmission() -> Bool {
        if showResult { return false }
        showResult = true
        cancelAnswerTimer()
        return true
    }

    func startAnswerTimer(onExpired: @escaping @MainActor () -> Void) {
        cancelAnswerTimer()
        remainingSeconds = Self.answerTimeLimitSeconds
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    guard let self else { return }
                    guard !self.showResult else { return }
                    self.remainingSeconds -= 1
                    if self.remainingSeconds <= 0 {
                        self.cancelAnswerTimer()
                        onExpired()
                    }
                }
            }
        }
    }

    func cancelAnswerTimer() {
        timerTask?.cancel()
        timerTask = nil
    }

    func reset() {
        cancelAnswerTimer()
        selectedAnswer = nil
        showResult = false
        result = nil
        remainingSeconds = Self.answerTimeLimitSeconds
    }
}
