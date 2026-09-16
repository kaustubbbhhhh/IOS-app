import SwiftUI

public struct DateDetailCard: View {
    let dayStat: DayStat
    let onDismiss: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(dayStat: DayStat, onDismiss: @escaping () -> Void) {
        self.dayStat = dayStat
        self.onDismiss = onDismiss
    }

    private var isGoalReached: Bool {
        dayStat.totalMillis >= dayStat.goalMillis && dayStat.goalMillis > 0
    }

    private var progressRatio: Double {
        guard dayStat.goalMillis > 0 else { return 0 }
        return min(max(Double(dayStat.totalMillis) / Double(dayStat.goalMillis), 0), 1.0)
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(dayStat.formattedFullDate)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))

                Spacer()

                Button(action: {
                    HapticManager.shared.impact(.light)
                    onDismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(AppColors.textSecondary(for: colorScheme).opacity(0.6))
                }
                .buttonStyle(.plain)
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Off-screen time")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    Text(DurationFormatter.formatDuration(millis: dayStat.totalMillis))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.primary(for: colorScheme))
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    Text("Goal")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    Text(DurationFormatter.formatDuration(millis: dayStat.goalMillis))
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary(for: colorScheme))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("Progress")
                        .font(.system(size: 11))
                        .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    Text(isGoalReached ? "\(dayStat.progressPercent)% ✓" : "\(dayStat.progressPercent)%")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(isGoalReached ? AppColors.tertiary(for: colorScheme) : AppColors.primary(for: colorScheme))
                }
            }

            // Progress Bar
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppColors.primary(for: colorScheme).opacity(0.15))
                        .frame(height: 6)

                    Capsule()
                        .fill(isGoalReached ? AppColors.tertiary(for: colorScheme) : AppColors.primary(for: colorScheme))
                        .frame(width: proxy.size.width * CGFloat(progressRatio), height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: progressRatio)
                }
            }
            .frame(height: 6)
        }
        .cardStyle(cornerRadius: 20, padding: 16)
    }
}
