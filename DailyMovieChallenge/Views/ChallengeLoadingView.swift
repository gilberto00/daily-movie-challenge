//
//  ChallengeLoadingView.swift
//  DailyMovieChallenge
//

import SwiftUI

struct ChallengeLoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(Color.blue.opacity(0.15), lineWidth: 8)
                    .frame(width: 68, height: 68)

                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(1.3)
                    .tint(.blue)
            }

            Text(String(localized: "home.loading"))
                .font(.headline)
                .foregroundColor(.primary)

            Text(String(localized: "home.loading_subtitle"))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 22)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.08))
        .cornerRadius(14)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    ChallengeLoadingView()
        .padding()
}
