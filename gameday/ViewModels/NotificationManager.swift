import Foundation
import UserNotifications

/// Schedules a single local reminder ahead of a game's first pitch.
@MainActor
@Observable
final class NotificationManager {
    /// How long before first pitch to fire the reminder.
    private let leadTime: TimeInterval = 60 * 60  // 1 hour

    private(set) var authorization: UNAuthorizationStatus = .notDetermined

    func refreshAuthorization() async {
        authorization = await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }

    /// Returns true if granted. Safe to call repeatedly.
    @discardableResult
    func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let granted = (try? await center.requestAuthorization(options: [.alert, .sound])) ?? false
        await refreshAuthorization()
        return granted
    }

    /// A stable id so a game's reminder can be scheduled/cancelled idempotently.
    private func identifier(for game: GameInfo, filter: GamedayFilter) -> String {
        "reminder:\(filter.id):\(game.startDate?.timeIntervalSince1970 ?? 0)"
    }

    func hasReminder(for game: GameInfo, filter: GamedayFilter) async -> Bool {
        let id = identifier(for: game, filter: filter)
        let pending = await UNUserNotificationCenter.current().pendingNotificationRequests()
        return pending.contains { $0.identifier == id }
    }

    /// Schedules a reminder `leadTime` before first pitch. Returns false if the
    /// game has no start, the reminder time is already in the past, or unauthorized.
    @discardableResult
    func scheduleReminder(for game: GameInfo, filter: GamedayFilter) async -> Bool {
        if authorization != .authorized && authorization != .provisional {
            guard await requestAuthorization() else { return false }
        }
        guard let start = game.startDate else { return false }
        let fireDate = start.addingTimeInterval(-leadTime)
        guard fireDate > Date() else { return false }

        let content = UNMutableNotificationContent()
        content.title = "Gameday"
        if let headline = game.matchupHeadline(for: filter) {
            content.body = "\(headline) — first pitch \(game.gameTime ?? "soon")."
        } else {
            content.body = "First pitch \(game.gameTime ?? "soon")."
        }
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(
            identifier: identifier(for: game, filter: filter),
            content: content,
            trigger: trigger
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
            return true
        } catch {
            return false
        }
    }

    func cancelReminder(for game: GameInfo, filter: GamedayFilter) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier(for: game, filter: filter)])
    }
}
