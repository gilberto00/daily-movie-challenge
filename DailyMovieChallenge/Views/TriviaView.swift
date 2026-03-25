//
//  TriviaView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI

struct TriviaView: View {
    let challenge: DailyChallenge
    let onBackToHome: () -> Void
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @StateObject private var gameViewModel = TriviaGameViewModel()
    @State private var navigateToResult = false
    @State private var result: ChallengeResult?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Cabeçalho compacto: poster pequeno + título (o poster grande da barra já existe)
                HStack(alignment: .center, spacing: 12) {
                    if let posterUrl = challenge.posterUrl, let url = URL(string: posterUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 56, height: 84)
                        }
                        .frame(width: 56, height: 84)
                        .clipped()
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                    }

                    Text(challenge.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top, 4)

                Divider()
                    .padding(.vertical, 4)

                let timerUrgent = gameViewModel.remainingSeconds <= 10
                let timerFraction = Double(gameViewModel.remainingSeconds)
                    / Double(TriviaGameViewModel.answerTimeLimitSeconds)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "timer")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(timerUrgent ? Color.red : Color.accentColor)
                        Text(
                            String(
                                format: String(localized: "trivia.time_remaining_format"),
                                locale: .current,
                                gameViewModel.remainingSeconds
                            )
                        )
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(timerUrgent ? Color.red : Color.primary)
                        Spacer(minLength: 0)
                    }
                    GeometryReader { geo in
                        let width = max(0, geo.size.width * timerFraction)
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color(.tertiarySystemFill))
                            Capsule()
                                .fill(timerUrgent ? Color.red : Color.blue)
                                .frame(width: max(width, timerFraction > 0 ? 6 : 0))
                        }
                    }
                    .frame(height: 10)
                    .accessibilityLabel(
                        String(
                            format: String(localized: "trivia.time_remaining_format"),
                            locale: .current,
                            gameViewModel.remainingSeconds
                        )
                    )
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .padding(.horizontal)

                // Question
                Text(challenge.question)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                    .lineLimit(4)
                    .padding(.horizontal, 4)

                // Answer Options - Layout adaptativo
                // Se as opções são curtas (anos, números), usar grid 2x2
                // Se são longas (textos), usar lista vertical
                let optionsAreShort = challenge.options.allSatisfy { $0.count <= 10 }
                
                if optionsAreShort && challenge.options.count == 4 {
                    // Grid 2x2 compacto para caber no ecrã sem scroll na maioria dos telemóveis
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 10),
                        GridItem(.flexible(), spacing: 10)
                    ], spacing: 10) {
                        ForEach(challenge.options, id: \.self) { option in
                            Button {
                                gameViewModel.selectAnswer(option)
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Text(option)
                                        .font(.body.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                        .minimumScaleFactor(0.8)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                    if gameViewModel.selectedAnswer == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.blue)
                                            .font(.body)
                                            .padding(6)
                                    }
                                }
                                .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 64)
                                .background(
                                    gameViewModel.selectedAnswer == option
                                        ? Color.blue.opacity(0.12)
                                        : Color.gray.opacity(0.1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .stroke(
                                            gameViewModel.selectedAnswer == option
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .disabled(gameViewModel.showResult)
                        }
                    }
                    .padding(.horizontal)
                } else {
                    // Lista vertical para opções longas ou quantidade diferente (pode precisar de scroll)
                    VStack(spacing: 12) {
                        ForEach(challenge.options, id: \.self) { option in
                            Button {
                                gameViewModel.selectAnswer(option)
                            } label: {
                                HStack {
                                    Text(option)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(3)
                                    Spacer()
                                    if gameViewModel.selectedAnswer == option {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    gameViewModel.selectedAnswer == option
                                        ? Color.blue.opacity(0.1)
                                        : Color.gray.opacity(0.1)
                                )
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            gameViewModel.selectedAnswer == option
                                                ? Color.blue
                                                : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .disabled(gameViewModel.showResult)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .scrollBounceBehavior(.basedOnSize)
        .safeAreaInset(edge: .bottom) {
            // Botão fixo acima da área segura - SwiftUI ajusta automaticamente o ScrollView
            VStack(spacing: 0) {
                Divider()
                
                Button {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    Task {
                        guard let selected = gameViewModel.selectedAnswer else { return }
                        guard gameViewModel.lockForSubmission() else { return }
                        let challengeResult = await challengeViewModel.submitAnswer(selected)
                        result = challengeResult
                        navigateToResult = true
                    }
                } label: {
                    Text(String(localized: "trivia.submit"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            gameViewModel.selectedAnswer != nil && !gameViewModel.showResult
                                ? Color.blue
                                : Color.gray
                        )
                        .cornerRadius(12)
                }
                .disabled(gameViewModel.selectedAnswer == nil || gameViewModel.showResult)
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(Color(.systemBackground))
            }
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.05), radius: 3, y: -2)
            )
        }
        .navigationTitle("Challenge")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack(spacing: 8) {
                    if let posterUrl = challenge.posterUrl, let url = URL(string: posterUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 30, height: 45)
                        .cornerRadius(6)
                        .clipped()
                    }
                    Text(String(localized: "trivia.challenge"))
                        .font(.headline)
                }
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = result {
                ResultView(
                    result: result,
                    challengeId: challenge.id,
                    movieId: challenge.movieId
                ) {
                    // Voltar direto para Home - limpar toda a pilha
                    navigateToResult = false
                    onBackToHome()
                }
                .environmentObject(challengeViewModel)
            }
        }
        .onAppear {
            gameViewModel.startAnswerTimer {
                Task {
                    guard gameViewModel.lockForSubmission() else { return }
                    let challengeResult = await challengeViewModel.submitAnswer(TriviaGameViewModel.timeoutSentinel)
                    result = challengeResult
                    navigateToResult = true
                }
            }
        }
        .onDisappear {
            gameViewModel.cancelAnswerTimer()
        }
    }
}

#Preview {
    NavigationStack {
        TriviaView(
            challenge: DailyChallenge(
                id: "2026-01-19",
                movieId: 27205,
                title: "Inception",
                posterUrl: nil,
                question: "In which year was this movie released?",
                options: ["2008", "2010", "2012", "2014"],
                correctAnswer: "2010",
                curiosity: "The rotating hallway scene was filmed using a real rotating set.",
                questionType: "year",
                isExtra: false
            ),
            onBackToHome: {}
        )
        .environmentObject(DailyChallengeViewModel())
    }
}
