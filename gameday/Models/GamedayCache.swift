import Foundation
import SwiftData

@Model
final class GamedayCache {
    // Inline defaults keep SwiftData lightweight migration happy across schema changes.
    var filterId: String = ""     // GamedayFilter.id, e.g. "team:111" or "venue:3"
    var date: String = ""         // "yyyy-MM-dd" in local time zone
    var games: [GameInfo] = []    // Codable value type — SwiftData persists the array
    var fetchedAt: Date = Date.distantPast

    init(filterId: String, date: String, info: GamedayInfo) {
        self.filterId = filterId
        self.date = date
        apply(info)
    }

    func apply(_ info: GamedayInfo) {
        games = info.games
        fetchedAt = Date()
    }

    var info: GamedayInfo {
        GamedayInfo(games: games)
    }
}
