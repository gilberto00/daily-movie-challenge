//
//  NotificationSettingsView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-24.
//

import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var notificationService = NotificationService.shared
    @State private var settings: NotificationSettings = NotificationSettings()
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showSuccessAlert = false
    
    var body: some View {
        List {
            Section {
                Toggle(String(localized: "settings.daily_challenge"), isOn: $settings.dailyChallenge)
                    .onChange(of: settings.dailyChallenge) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle(String(localized: "settings.streak_reminder"), isOn: $settings.streakReminder)
                    .onChange(of: settings.streakReminder) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle(String(localized: "settings.achievements"), isOn: $settings.achievements)
                    .onChange(of: settings.achievements) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle(String(localized: "settings.comment_notifications"), isOn: $settings.comments)
                    .onChange(of: settings.comments) { oldValue, newValue in
                        saveSettings()
                    }
            } header: {
                Text(String(localized: "settings.notification_preferences"))
            } footer: {
                Text(String(localized: "settings.preferences_footer"))
            }
            
            Section {
                HStack {
                    if notificationService.isAuthorized {
                        Label(String(localized: "settings.notifications_enabled"), systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label(String(localized: "settings.notifications_disabled"), systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if !notificationService.isAuthorized {
                        Button(String(localized: "settings.enable")) {
                            Task {
                                _ = await notificationService.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                if let fcmToken = notificationService.fcmToken {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "settings.fcm_token"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(fcmToken)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }
            } header: {
                Text(String(localized: "settings.status"))
            }
        }
        .navigationTitle(String(localized: "settings.navigation_title"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(String(localized: "settings.done")) {
                    dismiss()
                }
            }
        }
        .task {
            await loadSettings()
            // Tentar salvar token FCM ao abrir configurações (usuário autenticado, token pode estar pronto)
            await NotificationService.shared.saveTokenIfNeeded()
        }
        .alert(String(localized: "settings.settings_saved"), isPresented: $showSuccessAlert) {
            Button(String(localized: "settings.ok"), role: .cancel) { }
        } message: {
            Text(String(localized: "settings.preferences_saved"))
        }
        .alert(String(localized: "settings.error"), isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button(String(localized: "settings.ok"), role: .cancel) {
                errorMessage = nil
            }
        } message: {
            if let errorMessage = errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadSettings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            settings = try await notificationService.getNotificationSettings()
        } catch {
            errorMessage = String(format: String(localized: "settings.failed_to_load"), error.localizedDescription)
            print("❌ [NotificationSettingsView] Error loading settings: \(error)")
        }
        
        isLoading = false
    }
    
    private func saveSettings() {
        Task {
            do {
                try await notificationService.updateNotificationSettings(settings)
                await MainActor.run {
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    errorMessage = String(format: String(localized: "settings.failed_to_save"), error.localizedDescription)
                }
                print("❌ [NotificationSettingsView] Error saving settings: \(error)")
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationSettingsView()
    }
}
