import SwiftUI

public struct WeeklyAverageCard: View {
    let currentWeek: WeekData

    @Environment(\.colorScheme) private var colorScheme

    public init(currentWeek: WeekData) {
        self.currentWeek = currentWeek
    }

    public var body: some View {
        VStack(spacing: 6) {
            Text("WEEKLY AVERAGE")
                .font(.system(size: 11, weight: .bold))
                .tracking(1.2)
                .foregroundColor(AppColors.textSecondary(for: colorScheme))

            Text(currentWeek.averageMillis > 0 ? "Average: \(DurationFormatter.formatDuration(millis: currentWeek.averageMillis)) / day" : "Average: 0m / day")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textPrimary(for: colorScheme))

            Text(
                currentWeek.daysWithDataCount > 0
                ? "Based on \(currentWeek.daysWithDataCount) day(s) with recorded off-screen time"
                : "No recorded sessions for this week yet"
            )
            .font(.system(size: 12))
            .foregroundColor(AppColors.textSecondary(for: colorScheme).opacity(0.8))
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .cardStyle(cornerRadius: 20, padding: 16)
    }
}
