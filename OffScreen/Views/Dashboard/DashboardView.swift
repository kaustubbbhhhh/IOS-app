import SwiftUI

public struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel
    let onNavigateToHistory: () -> Void

    @Environment(\.colorScheme) private var colorScheme
    @State private var isStreakSheetPresented = false

    public init(viewModel: DashboardViewModel, onNavigateToHistory: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onNavigateToHistory = onNavigateToHistory
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Off-Screen Timer Card
                    OffScreenTimerCard(
                        todayTotalMillis: viewModel.todayTotalMillis,
                        isActive: viewModel.activeSession != nil
                    )

                    // 2. Daily Goal & Progress Ring
                    DailyProgressRing(
                        currentMillis: viewModel.todayTotalMillis,
                        goalMillis: viewModel.dailyGoalMillis,
                        onGoalTap: {
                            isStreakSheetPresented = true
                        }
                    )

                    // 3. Recent Sessions Header
                    HStack {
                        Text("Recent Sessions")
                            .font(AppTypography.headlineMedium)
                            .foregroundColor(AppColors.textPrimary(for: colorScheme))

                        Spacer()

                        Button(action: {
                            HapticManager.shared.impact(.light)
                            onNavigateToHistory()
                        }) {
                            HStack(spacing: 4) {
                                Text("Weekly Graph")
                                    .font(.system(size: 14, weight: .semibold))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                            }
                            .foregroundColor(AppColors.primary(for: colorScheme))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)

                    // 4. Session History List
                    SessionHistoryList(sessions: viewModel.todaySessions)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(AppColors.background(for: colorScheme))
            .navigationTitle("OffScreen")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        StreakBadge(
                            streakDays: viewModel.streakInfo.currentStreakDays,
                            action: { isStreakSheetPresented = true }
                        )

                        Button(action: {
                            HapticManager.shared.impact(.light)
                            onNavigateToHistory()
                        }) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(AppColors.primary(for: colorScheme))
                        }
                    }
                }
            }
            .refreshable {
                viewModel.refresh()
            }
            .sheet(isPresented: $isStreakSheetPresented) {
                GoalStreakSheet(
                    streakInfo: viewModel.streakInfo,
                    dailyGoalMillis: $viewModel.dailyGoalMillis,
                    onGoalChange: { newGoal in
                        viewModel.setDailyGoal(newGoal)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
}
