import Foundation
import SwiftData

@Model
public final class OffScreenSession {
    @Attribute(.unique) public var id: UUID
    public var startTime: Date
    public var endTime: Date?
    public var durationMillis: Int64?

    public init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        durationMillis: Int64? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.durationMillis = durationMillis
    }
    
    public var isActive: Bool {
        endTime == nil
    }
    
    public var computedDurationMillis: Int64 {
        if let durationMillis = durationMillis {
            return durationMillis
        }
        let end = endTime ?? Date()
        return Int64(end.timeIntervalSince(startTime) * 1000)
    }
}
