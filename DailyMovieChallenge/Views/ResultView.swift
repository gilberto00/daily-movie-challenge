//
//  ResultView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-19.
//

import SwiftUI
import UIKit

struct ResultView: View {
    let result: ChallengeResult
    let challengeId: String
    let movieId: Int
    let onBackToHome: () -> Void
    @EnvironmentObject var challengeViewModel: DailyChallengeViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.openURL) var openURL
    @State private var showCommentsSheet = false
    @State private var shouldReturnToHome = false
    @State private var commentsCount: Int = 0
    @State private var isLoadingCommentsCount = false
    @State private var showResult = false
    @State private var shakePhase: CGFloat = 0
    @State private var resultIconScale: CGFloat = 1.0
    @State private var isLoadingExtra = false
    @State private var navigateToExtraQuestion = false
    @State private var showShareSheet = false
    @State private var showChallengeShareSheet = false
    @State private var showCopyAlert = false
    @State private var dailyReminderEnabled = true
    @State private var isLoadingReminderSetting = false
    @State private var weeklyStatusDays: [WeeklyStatusDay] = []
    @State private var isLoadingWeeklyStatus = false
    
    // Computed property para verificar se todas as perguntas foram jogadas
    private var allQuestionsPlayed: Bool {
        challengeViewModel.areAllQuestionsPlayed(for: movieId)
    }

    private var shareMessage: String {
        let streak = max(challengeViewModel.userStreak, 0)
        if result.isCorrect {
            return String(format: String(localized: "result.share_message_correct"), streak)
        }
        return String(format: String(localized: "result.share_message_incorrect"), streak)
    }

    private var challengeShareURL: URL? {
        URL(string: "dailymoviechallenge://challenge/today")
    }

    private var challengeShareMessage: String {
        let streak = max(challengeViewModel.userStreak, 0)
        let link = challengeShareURL?.absoluteString ?? "dailymoviechallenge://challenge/today"
        return String(format: String(localized: "result.challenge_share_message"), streak, link)
    }

    private var challengeShareItems: [Any] {
        var items: [Any] = [challengeShareMessage]
        if let url = challengeShareURL {
            items.append(url)
        }
        return items
    }

    private var facebookShareURL: URL? {
        let appStoreURL = "https://apps.apple.com/app/id6758586246"
        var components = URLComponents(string: "https://www.facebook.com/sharer/sharer.php")
        components?.queryItems = [
            URLQueryItem(name: "u", value: appStoreURL),
            URLQueryItem(name: "quote", value: shareMessage)
        ]
        return components?.url
    }
    
    var body: some View {
        List {
            VStack(spacing: 24) {
                // Result Icon com animação (bounce no acerto, shake no erro)
                Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .foregroundColor(result.isCorrect ? .green : .red)
                    .scaleEffect(showResult ? resultIconScale : 0.5)
                    .opacity(showResult ? 1.0 : 0.0)
                    .offset(x: result.isCorrect ? 0 : sin(shakePhase * 2 * .pi) * 10)
                    .animation(.spring(response: 0.5, dampingFraction: result.isCorrect ? 0.55 : 0.7), value: showResult)
                    .animation(.linear(duration: 0.35), value: shakePhase)
                
                // Result Message com animação
                Text(result.isCorrect ? String(localized: "result.correct") : String(localized: "result.wrong"))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(result.isCorrect ? .green : .red)
                    .opacity(showResult ? 1.0 : 0.0)
                    .offset(y: showResult ? 0 : -20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: showResult)
                
                // Correct Answer (if wrong)
                if !result.isCorrect {
                    VStack(spacing: 8) {
                        Text(String(localized: "result.correct_answer"))
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(result.correctAnswer)
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // Curiosity
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "result.did_you_know"))
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(result.curiosity)
                        .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)

                if challengeViewModel.isDailyChallengeActive {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "result.quick_actions"))
                            .font(.headline)
                            .foregroundColor(.secondary)

                        // Bloco principal no estilo dos vídeos: ações rápidas em destaque.
                        HStack(spacing: 28) {
                            quickActionIconButton(
                                icon: "doc.on.doc",
                                label: String(localized: "result.copy_result")
                            ) {
                                UIPasteboard.general.string = shareMessage
                                showCopyAlert = true
                            }

                            quickActionIconButton(
                                icon: "square.and.arrow.up",
                                label: String(localized: "result.share_button")
                            ) {
                                showShareSheet = true
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                        .sheet(isPresented: $showShareSheet) {
                            ActivityView(
                                activityItems: [shareMessage],
                                subject: String(localized: "result.share_subject")
                            )
                        }

                        Button {
                            if let url = facebookShareURL {
                                openURL(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "f.circle.fill")
                                Text(String(localized: "result.share_facebook_button"))
                                    .font(.headline)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }

                        Button {
                            showChallengeShareSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "paperplane.fill")
                                Text(String(localized: "result.challenge_share_button"))
                                    .font(.headline)
                                Spacer()
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.teal)
                            .cornerRadius(12)
                        }
                        .sheet(isPresented: $showChallengeShareSheet) {
                            ActivityView(
                                activityItems: challengeShareItems,
                                subject: String(localized: "result.challenge_share_subject")
                            )
                        }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "result.weekly_status_title"))
                            .font(.headline)
                            .foregroundColor(.secondary)

                        WeeklyStatusView(
                            days: weeklyStatusDays,
                            isLoading: isLoadingWeeklyStatus,
                            streak: challengeViewModel.userStreak
                        )

                        Toggle(String(localized: "result.reminder_toggle"), isOn: $dailyReminderEnabled)
                            .disabled(isLoadingReminderSetting)
                            .onChange(of: dailyReminderEnabled) { oldValue, newValue in
                                Task {
                                    await updateDailyReminderSetting(isEnabled: newValue)
                                }
                            }
                    }
                    .padding()
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(12)
                }
                
                // View Comments Button com contador
                Button {
                    showCommentsSheet = true
                } label: {
                    HStack {
                        Text(String(localized: "result.view_comments"))
                            .font(.headline)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        if isLoadingCommentsCount {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        } else if commentsCount > 0 {
                            Text("\(commentsCount)")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // More Questions (Same Movie) Button
                Button {
                    Task {
                        isLoadingExtra = true
                        // Obter tipos já jogados do ViewModel
                        let excludeTypes = challengeViewModel.getPlayedQuestionTypes(for: movieId)
                        await challengeViewModel.loadExtraQuestion(movieId: movieId, excludeTypes: excludeTypes)
                        isLoadingExtra = false
                        if challengeViewModel.challenge != nil {
                            // Navegar direto para nova pergunta do mesmo filme
                            navigateToExtraQuestion = true
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: allQuestionsPlayed ? "checkmark.circle.fill" : "questionmark.circle.fill")
                        Text(allQuestionsPlayed ? String(localized: "result.all_questions_played") : String(localized: "result.more_questions"))
                            .font(.headline)
                        Spacer()
                        if isLoadingExtra {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(allQuestionsPlayed ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(isLoadingExtra || allQuestionsPlayed)
                
                // New Movie Challenge Button
                Button {
                    Task {
                        isLoadingExtra = true
                        print("🔄 [ResultView] Loading new movie challenge...")
                        await challengeViewModel.loadNewMovieChallenge()
                        
                        // Verificar se o desafio foi carregado
                        if let newChallenge = challengeViewModel.challenge {
                            print("✅ [ResultView] New challenge loaded: \(newChallenge.title) (ID: \(newChallenge.id))")
                            
                            // Resetar rastreamento de perguntas para novo filme
                            challengeViewModel.resetQuestionTracking()
                            
                            // AGUARDAR que o ViewModel termine completamente
                            // O loadNewMovieChallenge já deve ter setado isLoading = false
                            // Mas vamos garantir esperando um pouco mais
                            try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 segundos
                            
                            // Garantir que isLoading está false antes de voltar
                            await MainActor.run {
                                // Verificar estado atual
                                print("🔄 [ResultView] Verificando estado antes de voltar para Home")
                                print("🔄 [ResultView] isLoading ANTES: \(challengeViewModel.isLoading)")
                                print("🔄 [ResultView] challenge existe: \(challengeViewModel.challenge != nil)")
                                print("🔄 [ResultView] challenge title: \(challengeViewModel.challenge?.title ?? "nil")")
                                
                                // FORÇAR isLoading = false explicitamente
                                challengeViewModel.isLoading = false
                                isLoadingExtra = false
                                
                                print("🔄 [ResultView] Set isLoading = false explicitamente")
                                print("🔄 [ResultView] isLoading DEPOIS: \(challengeViewModel.isLoading)")
                                
                                // Verificar novamente após um delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    print("🔄 [ResultView] ⚠️ VERIFICAÇÃO FINAL antes de voltar para Home")
                                    print("🔄 [ResultView] isLoading FINAL: \(challengeViewModel.isLoading)")
                                    print("🔄 [ResultView] challenge existe: \(challengeViewModel.challenge != nil)")
                                    
                                    // Se ainda estiver loading, forçar novamente
                                    if challengeViewModel.isLoading {
                                        print("⚠️⚠️⚠️ [ResultView] CRÍTICO: isLoading ainda está true! Forçando false novamente...")
                                        challengeViewModel.isLoading = false
                                    }
                                    
                                    // Voltar para Home APENAS se isLoading estiver false
                                    if !challengeViewModel.isLoading {
                                        print("✅ [ResultView] Returning to Home with new challenge")
                                        onBackToHome()
                                    } else {
                                        print("❌ [ResultView] ERRO: Não posso voltar para Home - isLoading ainda está true!")
                                    }
                                }
                            }
                        } else {
                            print("❌ [ResultView] Failed to load new challenge")
                            await MainActor.run {
                                challengeViewModel.isLoading = false
                                isLoadingExtra = false
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "film.fill")
                        Text(String(localized: "result.new_movie_challenge"))
                            .font(.headline)
                        Spacer()
                        if isLoadingExtra {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(12)
                }
                .disabled(isLoadingExtra)

                // Back to Home Button
                Button {
                    print("🔄 [ResultView] Back to Home button pressionado")
                    onBackToHome()
                } label: {
                    Text(String(localized: "result.back_to_home"))
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                // Overflow garantido para sempre existir rolagem perceptível.
                Color.clear.frame(height: 220)
            }
            .padding()
            .padding(.bottom, 220)
            .listRowInsets(EdgeInsets())
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .scrollIndicators(.visible)
        .scrollBounceBehavior(.always)
        .simultaneousGesture(
            DragGesture(minimumDistance: 2)
                .onChanged { value in
                    #if DEBUG
                    print("🧭 [ResultView] drag changed dy=\(value.translation.height)")
                    #endif
                }
                .onEnded { value in
                    #if DEBUG
                    print("🧭 [ResultView] drag ended dy=\(value.translation.height)")
                    #endif
                }
        )
        .navigationTitle("Result")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(String(localized: "result.back_to_home")) {
                    onBackToHome()
                }
                .font(.subheadline.weight(.semibold))
            }
        }
        .task {
            // Haptic: sucesso no acerto, erro no incorreto
            let feedback = UINotificationFeedbackGenerator()
            feedback.prepare()
            if result.isCorrect {
                feedback.notificationOccurred(.success)
            } else {
                feedback.notificationOccurred(.error)
            }
            // Animar resultado ao aparecer
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                showResult = true
                resultIconScale = 1.0
            }
            // Acerto: leve bounce (scale 1.0 -> 1.15 -> 1.0)
            if result.isCorrect {
                try? await Task.sleep(nanoseconds: 200_000_000)
                withAnimation(.spring(response: 0.35, dampingFraction: 0.6)) {
                    resultIconScale = 1.15
                }
                try? await Task.sleep(nanoseconds: 150_000_000)
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    resultIconScale = 1.0
                }
            } else {
                // Erro: shake horizontal
                withAnimation(.linear(duration: 0.35)) {
                    shakePhase = 4
                }
            }
            await loadCommentsCount()
            await loadDailyReminderSetting()
            await loadWeeklyStatus()
        }
        .sheet(isPresented: $showCommentsSheet) {
            NavigationStack {
                CommentsView(challengeId: challengeId) {
                    // Marcar que deve voltar para Home
                    shouldReturnToHome = true
                    // Fechar o sheet
                    showCommentsSheet = false
                }
            }
            .presentationDetents([.medium, .large])
            .onDisappear {
                // Recarregar contagem quando o sheet fechar
                Task {
                    await loadCommentsCount()
                }
            }
        }
        .onChange(of: showCommentsSheet) { oldValue, isPresented in
            // Quando o sheet fechar, se deveria voltar para Home, chama o callback
            if !isPresented && shouldReturnToHome {
                shouldReturnToHome = false
                // Pequeno delay para garantir que a animação do sheet terminou
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    onBackToHome()
                }
            }
        }
        .alert(String(localized: "result.copied_title"), isPresented: $showCopyAlert) {
            Button(String(localized: "result.copied_ok"), role: .cancel) { }
        } message: {
            Text(String(localized: "result.copied_message"))
        }
        .animation(.default, value: commentsCount)
        .navigationDestination(isPresented: $navigateToExtraQuestion) {
            if let challenge = challengeViewModel.challenge {
                TriviaView(
                    challenge: challenge,
                    onBackToHome: {
                        onBackToHome()
                    }
                )
                .environmentObject(challengeViewModel)
            }
        }
    }
    
    private func loadCommentsCount() async {
        isLoadingCommentsCount = true
        do {
            commentsCount = try await FirestoreService.shared.getCommentsCount(challengeId: challengeId)
        } catch {
            print("⚠️ [ResultView] Error loading comments count: \(error.localizedDescription)")
            commentsCount = 0
        }
        isLoadingCommentsCount = false
    }

    private func loadDailyReminderSetting() async {
        guard challengeViewModel.isDailyChallengeActive else { return }
        isLoadingReminderSetting = true
        do {
            let settings = try await NotificationService.shared.getNotificationSettings()
            dailyReminderEnabled = settings.dailyChallenge
        } catch {
            print("⚠️ [ResultView] Error loading notification settings: \(error.localizedDescription)")
        }
        isLoadingReminderSetting = false
    }

    private func updateDailyReminderSetting(isEnabled: Bool) async {
        isLoadingReminderSetting = true
        do {
            var settings = try await NotificationService.shared.getNotificationSettings()
            settings.dailyChallenge = isEnabled
            try await NotificationService.shared.updateNotificationSettings(settings)
        } catch {
            print("⚠️ [ResultView] Error saving notification settings: \(error.localizedDescription)")
        }
        isLoadingReminderSetting = false
    }

    private func loadWeeklyStatus() async {
        guard let userId = AuthService.shared.getCurrentUserId() else { return }
        isLoadingWeeklyStatus = true
        do {
            weeklyStatusDays = try await FirestoreService.shared.fetchWeeklyStatus(userId: userId, days: 7)
        } catch {
            print("⚠️ [ResultView] Error loading weekly status: \(error.localizedDescription)")
            weeklyStatusDays = []
        }
        isLoadingWeeklyStatus = false
    }

    private func quickActionIconButton(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 48, height: 48)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ResultView(
            result: ChallengeResult(
                isCorrect: true,
                correctAnswer: "2010",
                curiosity: "The rotating hallway scene was filmed using a real rotating set."
            ),
            challengeId: "2026-01-19",
            movieId: 27205,
            onBackToHome: {}
        )
        .environmentObject(DailyChallengeViewModel())
    }
}

private struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let subject: String?

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        if let subject {
            controller.setValue(subject, forKey: "subject")
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
    }
}

