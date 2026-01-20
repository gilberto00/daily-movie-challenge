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
    @Published var selectedAnswer: String?
    @Published var showResult: Bool = false
    @Published var result: ChallengeResult?
    
    func selectAnswer(_ answer: String) {
        selectedAnswer = answer
    }
    
    func reset() {
        selectedAnswer = nil
        showResult = false
        result = nil
    }
}
