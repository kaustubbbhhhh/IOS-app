import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
public final class HistoryViewModel {
    private let repository: SessionRepository
    private let goalPreferences = GoalPreferences.shared

    public var weeks: [WeekData] = []
    public var streakInfo: StreakInfo = StreakInfo()
    public var dailyGoalMillis: Int64 = GoalPreferences.defaultGoalMillis
    public var selectedDay: DayStat? = nil

    public init(repository: SessionRepository) {
        self.repository = repository
        refresh()
    }

    public func refresh() {
        self.dailyGoalMillis = goalPreferences.dailyGoalMillis
        let today = Date().startOfDay
        let currentWeekMonday = today.startOfWeekMonday

        // 5 weeks total: 4 weeks ago up to current week (index 4 is current week)
        let weekStartDates: [Date] = (0...4).reversed().map { weeksAgo in
            currentWeekMonday.addingWeeks(-weeksAgo)
        }

        let streakStart = today.addingDays(-60)
        let latestDate = weekStartDates.last?.addingDays(7) ?? today.addingDays(7)
        let sessions = repository.getSessionsForRange(from: streakStart, to: latestDate)

        // Build Weeks Data
        var weeksList: [WeekData] = []
        let dayLabels = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]

        for (index, monday) in weekStartDates.enumerated() {
            let sunday = monday.addingDays(6)

            var daysList: [DayStat] = []
            for dayOffset in 0...6 {
                let date = monday.addingDays(dayOffset)
                let label = dayLabels[dayOffset]
                let isFuture = date > today
                let isToday = Calendar.current.isDate(date, inSameDayAs: today)

                let dayStart = date.startOfDay
                let dayEnd = date.endOfDay

                let dayTotalMillis: Int64
                if isFuture {
                    dayTotalMillis = 0
                } else {
                    dayTotalMillis = sessions
                        .filter { $0.startTime >= dayStart && $0.startTime <= dayEnd && $0.endTime != nil }
                        .reduce(0) { $0 + ($1.durationMillis ?? 0) }
                }

                let progressPercent = (dailyGoalMillis > 0 && !isFuture)
                    ? Int((Double(dayTotalMillis) / Double(dailyGoalMillis)) * 100)
                    : 0

                daysList.append(
                    DayStat(
                        date: date,
                        dayLabel: label,
                        formattedFullDate: date.formattedString(pattern: "EEEE, d MMMM"),
                        totalMillis: dayTotalMillis,
                        goalMillis: dailyGoalMillis,
                        progressPercent: progressPercent,
                        isFuture: isFuture,
                        isToday: isToday
                    )
                )
            }

            let weekTotalMillis = daysList.reduce(0) { $0 + $1.totalMillis }
            let daysWithData = daysList.filter { !$0.isFuture && $0.totalMillis > 0 }
            let daysWithDataCount = daysWithData.count
            let averageMillis = daysWithDataCount > 0 ? (weekTotalMillis / Int64(daysWithDataCount)) : 0

            let weekLabel: String
            if Calendar.current.isDate(monday, inSameDayAs: currentWeekMonday) {
                weekLabel = "This Week"
            } else if Calendar.current.isDate(monday, inSameDayAs: currentWeekMonday.addingWeeks(-1)) {
                weekLabel = "Last Week"
            } else {
                weekLabel = "\(monday.formattedString(pattern: "MMM d")) – \(sunday.formattedString(pattern: "MMM d"))"
            }

            let dateRangeLabel = "\(monday.formattedString(pattern: "MMM d")) – \(sunday.formattedString(pattern: "MMM d, yyyy"))"

            weeksList.append(
                WeekData(
                    weekIndex: index,
                    startDate: monday,
                    endDate: sunday,
                    weekLabel: weekLabel,
                    dateRangeLabel: dateRangeLabel,
                    days: daysList,
                    totalMillis: weekTotalMillis,
                    averageMillis: averageMillis,
                    daysWithDataCount: daysWithDataCount
                )
            )
        }

        self.weeks = weeksList

        // Calculate streak
        var dailyTotals: [Date: Int64] = [:]
        for session in sessions {
            if let duration = session.durationMillis {
                let sDate = session.startTime.startOfDay
                dailyTotals[sDate] = (dailyTotals[sDate] ?? 0) + duration
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
