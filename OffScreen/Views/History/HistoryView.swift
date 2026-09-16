import SwiftUI

public struct HistoryView: View {
    @Bindable var viewModel: HistoryViewModel

    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage: Int = 4 // Default to current week (last index)
    @State private var isStreakSheetPresented = false

    public init(viewModel: HistoryViewModel) {
        self.viewModel = viewModel
    }

    private var currentWeek: WeekData? {
        guard !viewModel.weeks.isEmpty, currentPage >= 0, currentPage < viewModel.weeks.count else {
            return nil
        }
        return viewModel.weeks[currentPage]
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if let week = currentWeek {
                    // ==========================================
                    // TOP SECTION (~25% of height)
                    // ==========================================
                    VStack(spacing: 8) {
                        // Week Navigator Row: Chevron < Week Label > Chevron
                        HStack {
                            Button(action: {
                                if currentPage > 0 {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        currentPage -= 1
                                        viewModel.selectedDay = nil
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(currentPage > 0 ? AppColors.textPrimary(for: colorScheme) : Color.gray.opacity(0.3))
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(currentPage <= 0)

                            Spacer()

                            VStack(spacing: 2) {
                                Text(week.weekLabel)
                                    .font(.system(size: 17, weight: .bold))
                                    .foregroundColor(AppColors.textPrimary(for: colorScheme))
                                Text(week.dateRangeLabel)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppColors.textSecondary(for: colorScheme))
                            }

                            Spacer()

                            Button(action: {
                                if currentPage < viewModel.weeks.count - 1 {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                                        currentPage += 1
                                        viewModel.selectedDay = nil
                                    }
                                }
                            }) {
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(currentPage < viewModel.weeks.count - 1 ? AppColors.textPrimary(for: colorScheme) : Color.gray.opacity(0.3))
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(currentPage >= viewModel.weeks.count - 1)
                        }
                        .padding(.horizontal, 8)

                        // Total Duration
                        Text(DurationFormatter.formatDuration(millis: week.totalMillis))
                            .font(AppTypography.displayLarge)
                            .foregroundColor(AppColors.primary(for: colorScheme))
                            .contentTransition(.numericText())

                        Text("Total off-screen this week")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppColors.textSecondary(for: colorScheme))
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                    // ==========================================
                    // MIDDLE SECTION (~45% of height)
                    // ==========================================
                    TabView(selection: $currentPage) {
                        ForEach(viewModel.weeks) { wData in
                            WeeklyBarGraph(
                                weekData: wData,
                                selectedDay: viewModel.selectedDay,
                                onDayClick: { day in
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        if viewModel.selectedDay?.date == day.date {
                                            viewModel.selectedDay = nil
                                        } else {
                                            viewModel.selectedDay = day
                                        }
                                    }
                                }
                            )
                            .tag(wData.weekIndex)
                            .padding(.horizontal, 18)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(minHeight: 220)
                    .onChange(of: currentPage) { _, _ in
                        viewModel.selectedDay = nil
                    }

                    // ==========================================
                    // BOTTOM SECTION (~30% of height)
                    // ==========================================
                    VStack(spacing: 12) {
                        // Page indicator dots
                        HStack(spacing: 6) {
                            ForEach(0..<viewModel.weeks.count, id: \.self) { index in
                                Circle()
                                    .fill(index == currentPage ? AppColors.primary(for: colorScheme) : Color.gray.opacity(0.3))
                                    .frame(width: index == currentPage ? 8 : 6, height: index == currentPage ? 8 : 6)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                            }
                        }
                        .padding(.top, 6)

                        // Date Detail or Weekly Average Card
                        if let selected = viewModel.selectedDay {
                            DateDetailCard(
                                dayStat: selected,
                                onDismiss: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                        viewModel.selectedDay = nil
                                    }
                                }
                            )
                            .padding(.horizontal, 18)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        } else {
                            WeeklyAverageCard(currentWeek: week)
                                .padding(.horizontal, 18)
                                .transition(.opacity)
                        }
                    }
                    .padding(.bottom, 18)
                } else {
                    ProgressView("Loading history...")
                        .frame(maxHeight: .infinity)
                }
            }
            .background(AppColors.background(for: colorScheme))
            .navigationTitle("Weekly Records")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    StreakBadge(
                        streakDays: viewModel.streakInfo.currentStreakDays,
                        action: { isStreakSheetPresented = true }
                    )
                }
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
            .onAppear {
                if !viewModel.weeks.isEmpty {
                    currentPage = viewModel.weeks.count - 1
                }
            }
        }
    }
}
