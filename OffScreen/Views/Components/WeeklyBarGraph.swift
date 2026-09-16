import SwiftUI

public struct WeeklyBarGraph: View {
    let weekData: WeekData
    let selectedDay: DayStat?
    let onDayClick: (DayStat) -> Void

    @Environment(\.colorScheme) private var colorScheme

    public init(
        weekData: WeekData,
        selectedDay: DayStat?,
        onDayClick: @escaping (DayStat) -> Void
    ) {
        self.weekData = weekData
        self.selectedDay = selectedDay
        self.onDayClick = onDayClick
    }

    private var maxMillis: Int64 {
        let maxRecorded = weekData.days.map { $0.totalMillis }.max() ?? 0
        let goal = weekData.days.first?.goalMillis ?? GoalPreferences.defaultGoalMillis
        return max(max(maxRecorded, goal), 3600 * 1000) // at least 1 hour for scaling
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(weekData.days) { day in
                let isSelected = selectedDay?.date == day.date
                let isGoalReached = day.totalMillis >= day.goalMillis && day.goalMillis > 0
                let heightRatio: CGFloat = day.isFuture ? 0.05 : CGFloat(Double(day.totalMillis) / Double(maxMillis))
                let clampedRatio = min(max(heightRatio, 0.05), 1.0)

                Button(action: {
                    HapticManager.shared.selection()
                    onDayClick(day)
                }) {
                    VStack(spacing: 8) {
                        // Bar Geometry
                        GeometryReader { proxy in
                            VStack {
                                Spacer(minLength: 0)
                                
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(barColor(for: day, isGoalReached: isGoalReached, isSelected: isSelected))
                                    .frame(height: proxy.size.height * clampedRatio)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(
                                                isSelected ? Color.white : (day.isToday ? AppColors.primary(for: colorScheme) : Color.clear),
                                                lineWidth: isSelected ? 2 : 1
                                            )
                                    )
                                    .shadow(
                                        color: isSelected ? AppColors.primary(for: colorScheme).opacity(0.4) : Color.clear,
                                        radius: 6,
                                        x: 0,
                                        y: 2
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)

                        // Day label
                        Text(day.dayLabel)
                            .font(.system(size: 12, weight: day.isToday ? .bold : .medium))
                            .foregroundColor(
                                day.isToday ? AppColors.primary(for: colorScheme) :
                                (day.isFuture ? AppColors.textSecondary(for: colorScheme).opacity(0.4) : AppColors.textPrimary(for: colorScheme))
                            )
                    }
                }
                .buttonStyle(.plain)
                .frame(maxHeight: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .cardStyle(cornerRadius: 24, padding: 16)
    }

    private func barColor(for day: DayStat, isGoalReached: Bool, isSelected: Bool) -> Color {
        if day.isFuture {
            return Color.gray.opacity(0.12)
        }
        if isGoalReached {
            return isSelected ? AppColors.tertiary(for: colorScheme) : AppColors.tertiary(for: colorScheme).opacity(0.85)
        }
        if day.isToday {
            return isSelected ? AppColors.primary(for: colorScheme) : AppColors.primary(for: colorScheme).opacity(0.9)
        }
        return isSelected ? AppColors.green80 : AppColors.primary(for: colorScheme).opacity(0.4)
    }
}
