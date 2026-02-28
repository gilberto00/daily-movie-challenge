//
//  WeeklyStatusView.swift
//  DailyMovieChallenge
//

import SwiftUI

struct WeeklyStatusView: View {
    let days: [WeeklyStatusDay]
    let isLoading: Bool
    let streak: Int

    private static let weekdayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE")
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(format: String(localized: "result.streak_format"), streak))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
            }

            if isLoading {
                ProgressView(String(localized: "result.weekly_status_loading"))
                    .progressViewStyle(.circular)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 8) {
                    ForEach(days) { day in
                        VStack(spacing: 6) {
                            Text(Self.weekdayFormatter.string(from: day.date).uppercased())
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            statusIcon(for: day.outcome)
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }

                HStack(spacing: 14) {
                    legendItem(icon: "checkmark.circle.fill", color: .green, text: String(localized: "result.weekly_status_success"))
                    legendItem(icon: "xmark.circle.fill", color: .red, text: String(localized: "result.weekly_status_fail"))
                    legendItem(icon: "circle.dashed", color: .gray, text: String(localized: "result.weekly_status_no_interaction"))
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
    }

    @ViewBuilder
    private func statusIcon(for outcome: DailyChallengeOutcome?) -> some View {
        switch outcome {
        case .success:
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        case .fail:
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.red)
        case .none:
            Image(systemName: "circle.dashed")
                .foregroundColor(.gray.opacity(0.8))
        }
    }

    private func legendItem(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(text)
        }
    }
}

#Preview {
    WeeklyStatusView(
        days: [],
        isLoading: true,
        streak: 3
    )
    .padding()
}
