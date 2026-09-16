import Foundation
import UserNotifications

public final class NotificationService {
    public static let shared = NotificationService()

    private init() {}

    public func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            return granted
        } catch {
            return false
        }
    }

    public func sendSessionSummaryNotification(totalMillis: Int64) {
        let content = UNMutableNotificationContent()
        content.title = "OffScreen Tracker"
        content.body = "Today's off-screen time: \(DurationFormatter.formatDuration(millis: totalMillis))"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "offscreen_summary_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    public func sendGoalReachedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Reached!"
        content.body = "Congratulations! You've achieved your daily off-screen goal today."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "offscreen_goal_reached",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
