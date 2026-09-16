import Foundation

public struct DayStat: Identifiable, Sendable {
    public var id: String { formattedFullDate }
    public let date: Date
    public let dayLabel: String            // "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
    public let formattedFullDate: String   // e.g. "Tuesday, 15 September"
    public let totalMillis: Int64
    public let goalMillis: Int64
    public let progressPercent: Int
    public let isFuture: Bool
    public let isToday: Bool

    public init(
        date: Date,
        dayLabel: String,
        formattedFullDate: String,
        totalMillis: Int64,
        goalMillis: Int64,
        progressPercent: Int,
        isFuture: Bool,
        isToday: Bool
    ) {
        self.date = date
        self.dayLabel = dayLabel
        self.formattedFullDate = formattedFullDate
        self.totalMillis = totalMillis
        self.goalMillis = goalMillis
        self.progressPercent = progressPercent
        self.isFuture = isFuture
        self.isToday = isToday
    }
}

public struct WeekData: Identifiable, Sendable {
    public var id: Int { weekIndex }
    public let weekIndex: Int              // 0 to 4 (4 is current week)
    public let startDate: Date             // Monday
    public let endDate: Date               // Sunday
    public let weekLabel: String           // e.g. "This Week", "Last Week", "Aug 25 – Aug 31"
    public let dateRangeLabel: String      // e.g. "Sep 8 – Sep 14, 2026"
    public let days: [DayStat]             // Exactly 7 days, Monday to Sunday
    public let totalMillis: Int64
    public let averageMillis: Int64
    public let daysWithDataCount: Int

    public init(
        weekIndex: Int,
        startDate: Date,
        endDate: Date,
        weekLabel: String,
        dateRangeLabel: String,
        days: [DayStat],
        totalMillis: Int64,
        averageMillis: Int64,
        daysWithDataCount: Int
    ) {
        self.weekIndex = weekIndex
        self.startDate = startDate
        self.endDate = endDate
        self.weekLabel = weekLabel
        self.dateRangeLabel = dateRangeLabel
        self.days = days
        self.totalMillis = totalMillis
        self.averageMillis = averageMillis
        self.daysWithDataCount = daysWithDataCount
    }
}
