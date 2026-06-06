import WidgetKit

struct GamedayEntry: TimelineEntry {
    let date: Date
    let filter: GamedayFilter
    let info: GamedayInfo
}

extension GamedayInfo {
    /// Sample data for placeholders, snapshots, and previews.
    static let gamedayPreview = GamedayInfo(games: [
        GameInfo(
            homeTeamId: 111, homeTeamName: "Boston Red Sox",
            awayTeamId: 147, awayTeamName: "New York Yankees",
            venueName: "Fenway Park", startDate: nil, gameTime: "7:10 PM", gameState: .preview
        )
    ])
}
