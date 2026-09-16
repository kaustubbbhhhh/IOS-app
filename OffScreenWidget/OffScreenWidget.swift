import WidgetKit
import SwiftUI

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalMillis: Int64
    let goalMillis: Int64
    let isActive: Bool
}

struct Provider: TimelineProvider {
    private let appGroupIdentifier = "group.com.offscreen.tracker"

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalMillis: 3 * 3600 * 1000 + 36 * 60 * 1000, goalMillis: 4 * 3600 * 1000, isActive: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = currentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let entry = currentEntry()
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> SimpleEntry {
        let defaults = UserDefaults(suiteName: appGroupIdentifier) ?? UserDefaults.standard
        let total = defaults.object(forKey: "widget_today_total_millis") as? Int64 ?? 0
        let goal = defaults.object(forKey: "widget_daily_goal_millis") as? Int64 ?? (4 * 3600 * 1000)
        let active = defaults.bool(forKey: "widget_is_active")

        return SimpleEntry(date: Date(), totalMillis: total, goalMillis: goal, isActive: active)
    }
}

struct OffScreenWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    private var progress: Double {
        guard entry.goalMillis > 0 else { return 0 }
        return min(max(Double(entry.totalMillis) / Double(entry.goalMillis), 0), 1.0)
    }

    private var percentage: Int {
        Int(progress * 100)
    }

    private var isGoalReached: Bool {
        entry.totalMillis >= entry.goalMillis && entry.goalMillis > 0
    }

    var body: some View {
        ZStack {
            Color(hex: 0x0F1A0F) // Dark green background matching Android widget
                .ignoresSafeArea()

            VStack(spacing: 8) {
                // Status Pill
                HStack(spacing: 5) {
                    Text(entry.isActive ? "🌙 Off-screen" : "● Screen on")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(entry.isActive ? Color(hex: 0xA5D6A7) : Color.gray)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    Capsule()
                        .fill(entry.isActive ? Color(hex: 0x1B5E20).opacity(0.6) : Color.white.opacity(0.1))
                )

                // Circular Donut Ring
                ZStack {
                    Circle()
                        .stroke(Color(hex: 0x2A422D), lineWidth: 9)

                    Circle()
                        .trim(from: 0, to: CGFloat(progress))
                        .stroke(
                            isGoalReached ? Color(hex: 0xFFFFD54F) : Color(hex: 0x81C784),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("\(formatShort(entry.totalMillis)) / \(formatShort(entry.goalMillis))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: 0xA5D6A7))

                        Text("\(percentage)%")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(isGoalReached ? Color(hex: 0xFFFFD54F) : .white)

                        if isGoalReached {
                            Text("★ GOAL REACHED")
                                .font(.system(size: 7, weight: .bold))
                                .foregroundColor(Color(hex: 0xFFFFD54F))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 1)
                                .background(
                                    Capsule()
                                        .stroke(Color(hex: 0xFFFFD54F), lineWidth: 1)
                                )
                        } else {
                            Text("DAILY GOAL")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(Color(hex: 0x819983))
                        }
                    }
                }
                .frame(width: 105, height: 105)
            }
            .padding(10)
        }
        .widgetURL(URL(string: "offscreen://open"))
    }

    private func formatShort(_ millis: Int64) -> String {
        let totalMinutes = millis / 60_000
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours == 0 && minutes == 0 { return "0h" }
        if hours > 0 && minutes > 0 { return "\(hours)h \(minutes)m" }
        if hours > 0 { return "\(hours)h" }
        return "\(minutes)m"
    }
}

extension Color {
    fileprivate init(hex: UInt, alpha: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

public struct OffScreenWidget: Widget {
    let kind: String = "OffScreenWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            OffScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("OffScreen Tracker")
        .description("Keep track of your daily off-screen progress at a glance.")
        .supportedFamilies([.systemSmall])
    }
}
