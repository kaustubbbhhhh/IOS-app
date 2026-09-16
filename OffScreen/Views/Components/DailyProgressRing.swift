import SwiftUI

public struct DailyProgressRing: View {
    let currentMillis: Int64
    let goalMillis: Int64
    let onGoalTap: () -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(currentMillis: Int64, goalMillis: Int64, onGoalTap: @escaping () -> Void) {
        self.currentMillis = currentMillis
        self.goalMillis = goalMillis
        self.onGoalTap = onGoalTap
    }

    private var progress: Double {
        guard goalMillis > 0 else { return 0 }
        return min(max(Double(currentMillis) / Double(goalMillis), 0), 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    private var isGoalReached: Bool {
        currentMillis >= goalMillis && goalMillis > 0
    }

    public var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("DAILY GOAL")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(AppColors.textSecondary(for: colorScheme))

                Text(DurationFormatter.formatDuration(millis: goalMillis))
                    .font(AppTypography.headlineMedium)
                    .foregroundColor(AppColors.textPrimary(for: colorScheme))

                if isGoalReached {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                        Text("Goal Reached!")
                            .font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(AppColors.tertiary(for: colorScheme))
                    .padding(.top, 2)
                } else {
                    Button(action: {
                        HapticManager.shared.impact(.light)
                        onGoalTap()
                    }) {
                        Text("Tap to adjust ›")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.primary(for: colorScheme))
                    }
                    .padding(.top, 2)
                }
            }

            Spacer()

            // Donut Ring Indicator
            ZStack {
                // Background Track
                Circle()
                    .stroke(
                        AppColors.primary(for: colorScheme).opacity(0.15),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )

                // Progress Arc
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        isGoalReached ? AppColors.tertiary(for: colorScheme) : AppColors.primary(for: colorScheme),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.8, dampingFraction: 0.7), value: progress)

                // Center percentage
                VStack(spacing: 0) {
                    Text("\(percentage)%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isGoalReached ? AppColors.tertiary(for: colorScheme) : AppColors.textPrimary(for: colorScheme))
                }
            }
            .frame(width: 90, height: 90)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(cornerRadius: 24, padding: 22)
    }
}
