import Foundation

public struct StreakCalculator {
    public static func calculateStreak(
        dailyTotals: [Date: Int64],
        goalMillis: Int64,
        today: Date = Date().startOfDay
    ) -> StreakInfo {
        let todayTotal = dailyTotals[today] ?? 0
        let isTodayAchieved = todayTotal >= goalMillis && goalMillis > 0

        var streakCount = 0
        var checkDate = isTodayAchieved ? today : today.addingDays(-1)

        while true {
            let totalForDate = dailyTotals[checkDate] ?? 0
            if totalForDate >= goalMillis && goalMillis > 0 {
                streakCount += 1
                checkDate = checkDate.addingDays(-1)
            } else {
                break
            }
        }

        let startDate: Date?
        let endDate: Date?
        let dateRangeStr: String

        if streakCount > 0 {
            let end = isTodayAchieved ? today : today.addingDays(-1)
            let start = end.addingDays(-(streakCount - 1))
            startDate = start
            endDate = end
            
            if Calendar.current.isDate(start, inSameDayAs: end) {
                dateRangeStr = end.formattedString(pattern: "d MMM")
            } else {
                dateRangeStr = "\(start.formattedString(pattern: "d MMM")) → \(end.formattedString(pattern: "d MMM"))"
            }
        } else {
            startDate = nil
            endDate = nil
            dateRangeStr = "Achieve your goal today to start a streak!"
        }

        // Generate past 30 days of achievement history (today backwards)
        var history: [DayAchievement] = []
        for daysAgo in 0..<30 {
            let date = today.addingDays(-daysAgo)
            let total = dailyTotals[date] ?? 0
            let isAchieved = total >= goalMillis && goalMillis > 0
            let isToday = Calendar.current.isDate(date, inSameDayAs: today)

            history.append(
                DayAchievement(
                    date: date,
                    formattedDate: date.formattedString(pattern: "d MMM"),
                    dayOfWeekLabel: date.formattedString(pattern: "EEE"),
                    totalMillis: total,
                    goalMillis: goalMillis,
                    isAchieved: isAchieved,
                    isToday: isToday,
                    isFuture: false
                )
            )
        }

        return StreakInfo(
            currentStreakDays: streakCount,
            startDate: startDate,
            endDate: endDate,
            formattedDateRange: dateRangeStr,
            isTodayAchieved: isTodayAchieved,
            achievementsHistory: history
        )
    }
}
