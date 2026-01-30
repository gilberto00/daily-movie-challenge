//
//  LeaderboardView.swift
//  DailyMovieChallenge
//
//  Created on 2026-01-20.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = LeaderboardViewModel()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text(String(localized: "leaderboard.title"))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(String(localized: "leaderboard.top_players"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // User's Position Card
                if let userEntry = viewModel.currentUserEntry {
                    VStack(spacing: 8) {
                        Text(String(localized: "leaderboard.your_position"))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        HStack {
                            if let rank = userEntry.rank {
                                Text("#\(rank)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(format: String(localized: "leaderboard.score_format"), userEntry.score))
                                    .font(.headline)
                                Text(String(format: String(localized: "leaderboard.streak_format"), userEntry.streak))
                                    .font(.subheadline)
                                Text(String(format: String(localized: "leaderboard.accuracy_format"), userEntry.accuracyRate))
                                    .font(.subheadline)
                                Text(String(format: String(localized: "leaderboard.challenges_format"), userEntry.totalChallenges))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Badges
                            if !userEntry.badges.isEmpty {
                                VStack(alignment: .trailing, spacing: 4) {
                                    ForEach(userEntry.badges.prefix(3), id: \.self) { badge in
                                        BadgeView(badgeName: badge)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Leaderboard List
                if viewModel.isLoading {
                    ProgressView(String(localized: "leaderboard.loading"))
                        .padding()
                } else if viewModel.entries.isEmpty {
                    Text(String(localized: "leaderboard.no_players"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRowView(
                                entry: entry,
                                isCurrentUser: entry.id == viewModel.currentUserEntry?.id,
                                position: index + 1
                            )
                            
                            if index < viewModel.entries.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            .padding()
        }
        .navigationTitle("Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(String(localized: "leaderboard.done")) {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadLeaderboard()
        }
        .refreshable {
            await viewModel.loadLeaderboard()
        }
    }
}

struct LeaderboardRowView: View {
    let entry: LeaderboardEntry
    let isCurrentUser: Bool
    let position: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Position/Rank
            Text(String(format: String(localized: "leaderboard.position_format"), position))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(position <= 3 ? .orange : .secondary)
                .frame(width: 40)
            
            // Medal icons for top 3
            if position == 1 {
                Image(systemName: "medal.fill")
                    .foregroundColor(.yellow)
                    .font(.title2)
            } else if position == 2 {
                Image(systemName: "medal.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            } else if position == 3 {
                Image(systemName: "medal.fill")
                    .foregroundColor(.brown)
                    .font(.title2)
            } else {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 32, height: 32)
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.username ?? String(localized: "leaderboard.player"))
                        .font(.headline)
                        .foregroundColor(isCurrentUser ? .blue : .primary)
                    
                    if isCurrentUser {
                        Text(String(localized: "leaderboard.you"))
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                
                HStack(spacing: 12) {
                    Label("\(entry.score)", systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Label("\(entry.streak)", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    
                    Text("\(entry.accuracyRate, specifier: "%.0f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Badges
            if !entry.badges.isEmpty {
                HStack(spacing: 4) {
                    ForEach(entry.badges.prefix(2), id: \.self) { badge in
                        BadgeView(badgeName: badge)
                    }
                    if entry.badges.count > 2 {
                        Text(String(format: String(localized: "leaderboard.badges_more_format"), entry.badges.count - 2))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(isCurrentUser ? Color.blue.opacity(0.1) : Color.clear)
    }
}

struct BadgeView: View {
    let badgeName: String
    
    var badgeInfo: (emoji: String, name: String) {
        switch badgeName {
        case "streak_7":
            return ("🔥", String(localized: "badge.7_days"))
        case "streak_30":
            return ("🔥🔥", String(localized: "badge.30_days"))
        case "challenges_100":
            return ("🎯", String(localized: "badge.100_challenges"))
        case "accuracy_80":
            return ("⭐", String(localized: "badge.80_accuracy"))
        default:
            return ("🏆", badgeName)
        }
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(badgeInfo.emoji)
                .font(.caption)
            Text(badgeInfo.name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(4)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(6)
    }
}

#Preview {
    NavigationStack {
        LeaderboardView()
    }
}
