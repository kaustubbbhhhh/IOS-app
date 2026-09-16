import XCTest
@testable import OffScreenKit

final class DurationFormatterTests: XCTestCase {
    func testFormatDurationZero() {
        XCTAssertEqual(DurationFormatter.formatDuration(millis: 0), "0h 00m")
    }

    func testFormatDurationMinutesOnly() {
        let fortyFiveMinutes: Int64 = 45 * 60 * 1000
        XCTAssertEqual(DurationFormatter.formatDuration(millis: fortyFiveMinutes), "0h 45m")
    }

    func testFormatDurationHoursAndMinutes() {
        let threeHoursThirtySixMinutes: Int64 = (3 * 60 + 36) * 60 * 1000
        XCTAssertEqual(DurationFormatter.formatDuration(millis: threeHoursThirtySixMinutes), "3h 36m")
    }

    func testFormatDurationExactHours() {
        let fourHours: Int64 = 4 * 60 * 60 * 1000
        XCTAssertEqual(DurationFormatter.formatDuration(millis: fourHours), "4h 00m")
    }

    func testFormatShortDuration() {
        XCTAssertEqual(DurationFormatter.formatShortDuration(millis: 0), "0h")
        XCTAssertEqual(DurationFormatter.formatShortDuration(millis: 4 * 3600 * 1000), "4h")
        XCTAssertEqual(DurationFormatter.formatShortDuration(millis: (3 * 60 + 36) * 60 * 1000), "3h 36m")
    }
}
