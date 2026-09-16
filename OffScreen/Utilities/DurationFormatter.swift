import Foundation

public struct DurationFormatter {
    /// Formats milliseconds into "Xh Ym" or "Ym" or "0h 00m"
    public static func formatDuration(millis: Int64) -> String {
        let totalMinutes = millis / 60_000
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours == 0 && minutes == 0 {
            return "0h 00m"
        } else if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h 00m"
        } else {
            return "0h \(minutes)m"
        }
    }
    
    /// Short format e.g. "3h 36m", "3h", "36m", or "0h"
    public static func formatShortDuration(millis: Int64) -> String {
        let totalMinutes = millis / 60_000
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        
        if hours == 0 && minutes == 0 {
            return "0h"
        } else if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }
    
    /// Formats timestamp into "10:30 AM"
    public static func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
