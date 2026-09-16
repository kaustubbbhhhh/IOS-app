import Foundation
import SwiftData

@MainActor
public final class SessionRepository {
    private let modelContext: ModelContext
    private let appGroupIdentifier = "group.com.offscreen.tracker"

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    public func startSession(at time: Date = Date()) {
        if getActiveSession() != nil {
            return // Session already running
        }
        let newSession = OffScreenSession(startTime: time)
        modelContext.insert(newSession)
        try? modelContext.save()
        syncWithWidget()
    }

    public func endSession(at time: Date = Date()) {
        guard let active = getActiveSession() else { return }
        active.endTime = time
        active.durationMillis = Int64(time.timeIntervalSince(active.startTime) * 1000)
        try? modelContext.save()
        syncWithWidget()
    }

    public func getActiveSession() -> OffScreenSession? {
        var descriptor = FetchDescriptor<OffScreenSession>(
            predicate: #Predicate { $0.endTime == nil },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return (try? modelContext.fetch(descriptor))?.first
    }

    public func getTodaySessions() -> [OffScreenSession] {
        let startOfDay = Date().startOfDay
        let endOfDay = Date().endOfDay
        let descriptor = FetchDescriptor<OffScreenSession>(
            predicate: #Predicate { session in
                session.startTime >= startOfDay && session.startTime <= endOfDay
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func getTodayTotalMillis() -> Int64 {
        let sessions = getTodaySessions()
        var total: Int64 = 0
        for session in sessions {
            if let duration = session.durationMillis {
                total += duration
            } else if session.isActive {
                total += Int64(Date().timeIntervalSince(session.startTime) * 1000)
            }
        }
        return total
    }

    public func getSessionsForRange(from start: Date, to end: Date) -> [OffScreenSession] {
        let descriptor = FetchDescriptor<OffScreenSession>(
            predicate: #Predicate { session in
                session.startTime >= start && session.startTime <= end
            },
            sortBy: [SortDescriptor(\.startTime, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    /// Syncs today's total, goal, and active status to AppGroup UserDefaults for WidgetKit
    public func syncWithWidget() {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        let total = getTodayTotalMillis()
        let active = getActiveSession() != nil
        let goal = GoalPreferences.shared.dailyGoalMillis
        
        defaults.set(total, forKey: "widget_today_total_millis")
        defaults.set(active, forKey: "widget_is_active")
        defaults.set(goal, forKey: "widget_daily_goal_millis")
        defaults.set(Date().timeIntervalSince1970, forKey: "widget_last_updated")
    }
}
