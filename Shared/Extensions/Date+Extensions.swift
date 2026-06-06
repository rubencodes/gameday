import Foundation

extension Date {
    // yyyy-MM-dd key used for MLB schedule API requests and cache lookups.
    // Cached formatter avoids repeated DateFormatter allocation.
    var scheduleKey: String {
        Self.scheduleKeyFormatter.string(from: self)
    }

    fileprivate static let scheduleKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter
    }()

    /// Localized medium date for display, e.g. "Jun 2, 2026".
    var mediumLabel: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }
}

extension String {
    /// Parse a "yyyy-MM-dd" schedule date string back into a Date.
    var scheduleDate: Date? {
        Date.scheduleKeyFormatter.date(from: self)
    }
}
