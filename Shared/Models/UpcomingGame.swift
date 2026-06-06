import Foundation

/// The soonest game after a given date, used for the "No game today — next: …" line.
struct UpcomingGame: Sendable, Equatable {
    let date: Date
    let game: GameInfo
}
