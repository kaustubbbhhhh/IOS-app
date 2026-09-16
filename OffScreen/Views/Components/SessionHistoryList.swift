import SwiftUI

public struct SessionHistoryList: View {
    let sessions: [OffScreenSession]

    @Environment(\.colorScheme) private var colorScheme

    public init(sessions: [OffScreenSession]) {
        self.sessions = sessions
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if sessions.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "moon.zzz")
                            .font(.system(size: 32))
                            .foregroundColor(AppColors.textSecondary(for: colorScheme).opacity(0.5))
                        Text("No sessions recorded today yet")
                            .font(AppTypography.bodyMedium)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        Text("Lock your screen to start tracking!")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary(for: colorScheme).opacity(0.7))
                    }
                    .padding(.vertical, 24)
                    Spacer()
                }
                .cardStyle(cornerRadius: 20, padding: 16)
            } else {
                VStack(spacing: 8) {
                    ForEach(sessions) { session in
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(AppColors.primary(for: colorScheme).opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Image(systemName: session.isActive ? "moon.fill" : "moon.stars.fill")
                                    .font(.system(size: 15))
                                    .foregroundColor(AppColors.primary(for: colorScheme))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(timeRangeText(for: session))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                                
                                Text(session.isActive ? "Currently in progress" : "Completed session")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            }

                            Spacer()

                            Text(durationText(for: session))
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primary(for: colorScheme))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(AppColors.primary(for: colorScheme).opacity(0.1))
                                )
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(AppColors.cardBackground(for: colorScheme))
                        )
                    }
                }
            }
        }
    }

    private func timeRangeText(for session: OffScreenSession) -> String {
        let start = DurationFormatter.formatTime(date: session.startTime)
        if let end = session.endTime {
            return "\(start) – \(DurationFormatter.formatTime(date: end))"
        } else {
            return "\(start) – Now"
        }
    }

    private func durationText(for session: OffScreenSession) -> String {
        DurationFormatter.formatDuration(millis: session.computedDurationMillis)
    }
}
