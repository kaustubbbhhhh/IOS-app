import SwiftUI

public struct GoalStreakSheet: View {
    let streakInfo: StreakInfo
    @Binding var dailyGoalMillis: Int64
    let onGoalChange: (Int64) -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isEditingGoal = false
    @State private var localGoalMillis: Int64 = GoalPreferences.defaultGoalMillis

    private let presetHours = [1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24]

    public init(
        streakInfo: StreakInfo,
        dailyGoalMillis: Binding<Int64>,
        onGoalChange: @escaping (Int64) -> Void
    ) {
        self.streakInfo = streakInfo
        self._dailyGoalMillis = dailyGoalMillis
        self.onGoalChange = onGoalChange
        self._localGoalMillis = State(initialValue: dailyGoalMillis.wrappedValue)
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Current Streak Hero Card
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(AppColors.flameColor.opacity(0.18))
                                .frame(width: 58, height: 58)
                            Text("🔥")
                                .font(.system(size: 30))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            Text("CURRENT STREAK")
                                .font(.system(size: 11, weight: .bold))
                                .tracking(1.2)
                                .foregroundColor(AppColors.flameColor)

                            Text(streakInfo.currentStreakDays > 0 ? "\(streakInfo.currentStreakDays) \(streakInfo.currentStreakDays == 1 ? "day" : "days")" : "0 days")
                                .font(AppTypography.displayMedium)
                                .foregroundColor(AppColors.textPrimary(for: colorScheme))

                            Text(streakInfo.formattedDateRange)
                                .font(AppTypography.bodyMedium)
                                .foregroundColor(AppColors.textSecondary(for: colorScheme))
                        }

                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle(cornerRadius: 22, padding: 18)

                    // 2. Daily Goal Section
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            VStack(alignment: .leading, spacing: 3) {
                                Text("DAILY GOAL")
                                    .font(.system(size: 11, weight: .bold))
                                    .tracking(1.2)
                                    .foregroundColor(AppColors.textSecondary(for: colorScheme))

                                Text(DurationFormatter.formatDuration(millis: localGoalMillis))
                                    .font(AppTypography.headlineLarge)
                                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                            }

                            Spacer()

                            Button(action: {
                                HapticManager.shared.impact(.light)
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    isEditingGoal.toggle()
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: isEditingGoal ? "checkmark" : "pencil")
                                        .font(.system(size: 13, weight: .semibold))
                                    Text(isEditingGoal ? "Done" : "Change Goal")
                                        .font(.system(size: 13, weight: .semibold))
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background(
                                    Capsule()
                                        .fill(AppColors.primary(for: colorScheme).opacity(0.12))
                                )
                                .foregroundColor(AppColors.primary(for: colorScheme))
                            }
                            .buttonStyle(.plain)
                        }

                        // Expandable Editor
                        if isEditingGoal {
                            VStack(alignment: .leading, spacing: 14) {
                                Divider()

                                Text("Select Preset (0h – 24h)")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary(for: colorScheme))

                                // Presets Grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                                    ForEach(presetHours, id: \.self) { hours in
                                        let targetMillis = Int64(hours) * 3600 * 1000
                                        let isSelected = localGoalMillis == targetMillis

                                        Button(action: {
                                            HapticManager.shared.selection()
                                            localGoalMillis = targetMillis
                                            dailyGoalMillis = targetMillis
                                            onGoalChange(targetMillis)
                                        }) {
                                            Text("\(hours)h")
                                                .font(.system(size: 14, weight: .semibold))
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                                        .fill(isSelected ? AppColors.primary(for: colorScheme) : AppColors.primary(for: colorScheme).opacity(0.1))
                                                )
                                                .foregroundColor(isSelected ? .white : AppColors.primary(for: colorScheme))
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                // Fine adjustment stepper
                                HStack {
                                    Text("Fine adjust (±30m)")
                                        .font(.system(size: 13))
                                        .foregroundColor(AppColors.textSecondary(for: colorScheme))

                                    Spacer()

                                    HStack(spacing: 12) {
                                        Button(action: {
                                            HapticManager.shared.impact(.light)
                                            let newMillis = max(localGoalMillis - 30 * 60 * 1000, 0)
                                            localGoalMillis = newMillis
                                            dailyGoalMillis = newMillis
                                            onGoalChange(newMillis)
                                        }) {
                                            Image(systemName: "minus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(localGoalMillis > 0 ? AppColors.primary(for: colorScheme) : Color.gray.opacity(0.3))
                                        }
                                        .disabled(localGoalMillis <= 0)

                                        Text(DurationFormatter.formatDuration(millis: localGoalMillis))
                                            .font(.system(size: 14, weight: .bold, design: .rounded))
                                            .frame(minWidth: 60)

                                        Button(action: {
                                            HapticManager.shared.impact(.light)
                                            let newMillis = min(localGoalMillis + 30 * 60 * 1000, 24 * 3600 * 1000)
                                            localGoalMillis = newMillis
                                            dailyGoalMillis = newMillis
                                            onGoalChange(newMillis)
                                        }) {
                                            Image(systemName: "plus.circle.fill")
                                                .font(.system(size: 24))
                                                .foregroundColor(localGoalMillis < 24 * 3600 * 1000 ? AppColors.primary(for: colorScheme) : Color.gray.opacity(0.3))
                                        }
                                        .disabled(localGoalMillis >= 24 * 3600 * 1000)
                                    }
                                }
                                .padding(.top, 6)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .cardStyle(cornerRadius: 22, padding: 18)

                    // 3. Achievement History
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ACHIEVEMENT HISTORY")
                            .font(.system(size: 11, weight: .bold))
                            .tracking(1.2)
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))

                        VStack(spacing: 8) {
                            ForEach(streakInfo.achievementsHistory) { achievement in
                                HStack(spacing: 12) {
                                    ZStack {
                                        Circle()
                                            .fill(achievement.isAchieved ? AppColors.green40.opacity(0.18) : Color.gray.opacity(0.12))
                                            .frame(width: 28, height: 28)
                                        Image(systemName: achievement.isAchieved ? "checkmark" : "xmark")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(achievement.isAchieved ? AppColors.green40 : AppColors.textSecondary(for: colorScheme).opacity(0.6))
                                    }

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("\(achievement.formattedDate) (\(achievement.dayOfWeekLabel))")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(AppColors.textPrimary(for: colorScheme))
                                        Text(achievement.isAchieved ? "Goal achieved" : "Goal not achieved")
                                            .font(.system(size: 11))
                                            .foregroundColor(achievement.isAchieved ? AppColors.green40 : AppColors.textSecondary(for: colorScheme))
                                    }

                                    Spacer()

                                    Text(DurationFormatter.formatDuration(millis: achievement.totalMillis))
                                        .font(.system(size: 13, weight: .bold, design: .rounded))
                                        .foregroundColor(achievement.isAchieved ? AppColors.green40 : AppColors.textSecondary(for: colorScheme))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(AppColors.cardBackground(for: colorScheme))
                                )
                            }
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Goals & Streak")
            .navigationBarTitleDisplayMode(.inline)
            .background(AppColors.background(for: colorScheme))
        }
    }
}
