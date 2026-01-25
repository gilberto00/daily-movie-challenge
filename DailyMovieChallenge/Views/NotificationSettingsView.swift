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
                Toggle("Daily Challenge Notifications", isOn: $settings.dailyChallenge)
                    .onChange(of: settings.dailyChallenge) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle("Streak Reminder", isOn: $settings.streakReminder)
                    .onChange(of: settings.streakReminder) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle("Achievements & Badges", isOn: $settings.achievements)
                    .onChange(of: settings.achievements) { oldValue, newValue in
                        saveSettings()
                    }
                
                Toggle("Comment Notifications", isOn: $settings.comments)
                    .onChange(of: settings.comments) { oldValue, newValue in
                        saveSettings()
                    }
            } header: {
                Text("Notification Preferences")
            } footer: {
                Text("Choose which types of notifications you want to receive. Daily Challenge and Streak Reminder notifications are sent at scheduled times.")
            }
            
            Section {
                HStack {
                    if notificationService.isAuthorized {
                        Label("Notifications Enabled", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Label("Notifications Disabled", systemImage: "xmark.circle.fill")
                            .foregroundColor(.red)
                    }
                    
                    Spacer()
                    
                    if !notificationService.isAuthorized {
                        Button("Enable") {
                            Task {
                                _ = await notificationService.requestAuthorization()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                if let fcmToken = notificationService.fcmToken {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("FCM Token")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(fcmToken)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                }
            } header: {
                Text("Status")
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .task {
            await loadSettings()
        }
        .alert("Settings Saved", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your notification preferences have been saved.")
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {
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
            errorMessage = "Failed to load settings: \(error.localizedDescription)"
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
                    errorMessage = "Failed to save settings: \(error.localizedDescription)"
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
