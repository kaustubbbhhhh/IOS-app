import Foundation

extension Date {
    public var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    public var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    public var startOfWeekMonday: Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // Monday is 2 in Gregorian
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    public func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    public func addingWeeks(_ weeks: Int) -> Date {
        Calendar.current.date(byAdding: .weekOfYear, value: weeks, to: self) ?? self
    }
    
    public var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    
    public var isFuture: Bool {
        self > Date().endOfDay
    }
    
    public func formattedString(pattern: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = pattern
        return formatter.string(from: self)
    }
}
