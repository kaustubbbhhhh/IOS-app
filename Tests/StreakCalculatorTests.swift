import XCTest
@testable import OffScreenKit

final class StreakCalculatorTests: XCTestCase {
    func testStreakWhenNoData() {
        let streak = StreakCalculator.calculateStreak(
            dailyTotals: [:],
            goalMillis: 4 * 3600 * 1000,
            today: Date().startOfDay
        )
        XCTAssertEqual(streak.currentStreakDays, 0)
        XCTAssertFalse(streak.isTodayAchieved)
        XCTAssertEqual(streak.achievementsHistory.count, 30)
    }

    func testStreakWithConsecutiveAchievedDays() {
        let today = Date().startOfDay
        let goal: Int64 = 4 * 3600 * 1000

        var dailyTotals: [Date: Int64] = [:]
        // Today achieved
        dailyTotals[today] = 5 * 3600 * 1000
        // Yesterday achieved
        dailyTotals[today.addingDays(-1)] = 4 * 3600 * 1000
        // 2 days ago achieved
        dailyTotals[today.addingDays(-2)] = 6 * 3600 * 1000
        // 3 days ago missed
        dailyTotals[today.addingDays(-3)] = 2 * 3600 * 1000

        let streak = StreakCalculator.calculateStreak(
            dailyTotals: dailyTotals,
            goalMillis: goal,
            today: today
        )

        XCTAssertEqual(streak.currentStreakDays, 3)
        XCTAssertTrue(streak.isTodayAchieved)
    }

    func testStreakWhenTodayNotYetAchievedButYesterdayWas() {
        let today = Date().startOfDay
        let goal: Int64 = 4 * 3600 * 1000

        var dailyTotals: [Date: Int64] = [:]
        // Today in progress (not achieved yet)
        dailyTotals[today] = 1 * 3600 * 1000
        // Yesterday achieved
        dailyTotals[today.addingDays(-1)] = 4 * 3600 * 1000
        // 2 days ago achieved
        dailyTotals[today.addingDays(-2)] = 4 * 3600 * 1000

        let streak = StreakCalculator.calculateStreak(
            dailyTotals: dailyTotals,
            goalMillis: goal,
            today: today
        )

        // Streak holds from yesterday until today ends
        XCTAssertEqual(streak.currentStreakDays, 2)
        XCTAssertFalse(streak.isTodayAchieved)
    }
}
