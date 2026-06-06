import Foundation

/// All games matching a (filter, date). Usually 0 or 1, but a doubleheader (or a
/// venue hosting two games in a day) yields more than one.
struct GamedayInfo: Sendable, Equatable {
    let games: [GameInfo]

    var isGameday: Bool { !games.isEmpty }
    var primary: GameInfo? { games.first }

    static let noGame = GamedayInfo(games: [])
}
