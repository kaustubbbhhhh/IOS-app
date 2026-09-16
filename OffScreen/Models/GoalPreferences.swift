import Foundation
import SwiftUI

@Observable
public final class GoalPreferences {
    public static let shared = GoalPreferences()
    
    public static let defaultGoalMillis: Int64 = 4 * 60 * 60 * 1000 // 4 hours
    public static let minGoalMillis: Int64 = 0
    public static let maxGoalMillis: Int64 = 24 * 60 * 60 * 1000
    
    private let appGroupIdentifier = "group.com.offscreen.tracker"
    private let keyDailyGoal = "daily_goal_millis"
    private let keyOnboardingDone = "onboarding_completed"
    
    private var userDefaults: UserDefaults {
        UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
    }
    
    public var dailyGoalMillis: Int64 {
        didSet {
            let clamped = min(max(dailyGoalMillis, GoalPreferences.minGoalMillis), GoalPreferences.maxGoalMillis)
            userDefaults.set(clamped, forKey: keyDailyGoal)
        }
    }
    
    public var isOnboardingCompleted: Bool {
        didSet {
            userDefaults.set(isOnboardingCompleted, forKey: keyOnboardingDone)
        }
    }
    
    private init() {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        let storedGoal = defaults.object(forKey: keyDailyGoal) as? Int64 ?? GoalPreferences.defaultGoalMillis
        self.dailyGoalMillis = min(max(storedGoal, GoalPreferences.minGoalMillis), GoalPreferences.maxGoalMillis)
        self.isOnboardingCompleted = defaults.bool(forKey: keyOnboardingDone)
    }
    
    public func setGoal(hours: Int) {
        let millis = Int64(hours) * 3600 * 1000
        self.dailyGoalMillis = millis
    }
    
    public func adjustGoal(byDeltaMinutes delta: Int) {
        let deltaMillis = Int64(delta) * 60 * 1000
        let newGoal = dailyGoalMillis + deltaMillis
        self.dailyGoalMillis = min(max(newGoal, GoalPreferences.minGoalMillis), GoalPreferences.maxGoalMillis)
    }
}
