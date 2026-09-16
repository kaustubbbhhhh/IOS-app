import Foundation

public struct DayAchievement: Identifiable, Sendable {
    public var id: String { formattedDate }
    public let date: Date
    public let formattedDate: String      // e.g. "15 Sep"
    public let dayOfWeekLabel: String     // e.g. "Tue"
    public let totalMillis: Int64
    public let goalMillis: Int64
    public let isAchieved: Bool
    public let isToday: Bool
    public let isFuture: Bool

    public init(
        date: Date,
        formattedDate: String,
        dayOfWeekLabel: String,
        totalMillis: Int64,
        goalMillis: Int64,
        isAchieved: Bool,
        isToday: Bool,
        isFuture: Bool
    ) {
        self.date = date
        self.formattedDate = formattedDate
        self.dayOfWeekLabel = dayOfWeekLabel
        self.totalMillis = totalMillis
        self.goalMillis = goalMillis
        self.isAchieved = isAchieved
        self.isToday = isToday
        self.isFuture = isFuture
    }
}

public struct StreakInfo: Sendable {
    public let currentStreakDays: Int
    public let startDate: Date?
    public let endDate: Date?
    public let formattedDateRange: String
    public let isTodayAchieved: Bool
    public let achievementsHistory: [DayAchievement]

    public init(
        currentStreakDays: Int = 0,
        startDate: Date? = nil,
        endDate: Date? = nil,
        formattedDateRange: String = "Achieve your goal today to start a streak!",
        isTodayAchieved: Bool = false,
        achievementsHistory: [DayAchievement] = []
    ) {
        self.currentStreakDays = currentStreakDays
        self.startDate = startDate
        self.endDate = endDate
        self.formattedDateRange = formattedDateRange
        self.isTodayAchieved = isTodayAchieved
        self.achievementsHistory = achievementsHistory
    }
}
