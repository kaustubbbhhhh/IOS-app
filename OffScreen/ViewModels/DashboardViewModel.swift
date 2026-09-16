import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
public final class DashboardViewModel {
    private let repository: SessionRepository
    private let goalPreferences = GoalPreferences.shared

    public var todayTotalMillis: Int64 = 0
    public var todaySessions: [OffScreenSession] = []
    public var activeSession: OffScreenSession?
    public var dailyGoalMillis: Int64 = GoalPreferences.defaultGoalMillis
    public var streakInfo: StreakInfo = StreakInfo()

    public init(repository: SessionRepository) {
        self.repository = repository
        refresh()
    }

    public func refresh() {
        self.todayTotalMillis = repository.getTodayTotalMillis()
        self.todaySessions = repository.getTodaySessions()
        self.activeSession = repository.getActiveSession()
        self.dailyGoalMillis = goalPreferences.dailyGoalMillis

        // Calculate streak from past 60 days
        let today = Date().startOfDay
        let start = today.addingDays(-60)
        let end = today.addingDays(1)
        let sessions = repository.getSessionsForRange(from: start, to: end)

        var dailyTotals: [Date: Int64] = [:]
        for session in sessions {
            if let duration = session.durationMillis {
                let sessionDate = session.startTime.startOfDay
                dailyTotals[sessionDate] = (dailyTotals[sessionDate] ?? 0) + duration
            }
        }
        self.streakInfo = StreakCalculator.calculateStreak(
            dailyTotals: dailyTotals,
            goalMillis: dailyGoalMillis,
            today: today
        )
    }

    public func setDailyGoal(_ millis: Int64) {
        goalPreferences.dailyGoalMillis = millis
        self.dailyGoalMillis = millis
        refresh()
    }
}
