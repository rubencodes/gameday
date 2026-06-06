import SwiftUI

struct GamedayPanel: View {
    let info: GamedayInfo
    let filter: GamedayFilter
    let date: Date
    var nextGame: UpcomingGame? = nil

    @Environment(\.colorScheme) private var colorScheme
    private var accent: Color { filter.theme.accent(for: colorScheme) }

    /// True once first pitch has passed (game in progress or finished).
    private func hasStarted(_ game: GameInfo) -> Bool {
        guard let start = game.startDate else { return false }
        return start < Date()
    }

    private var questionLabel: String {
        if Calendar.current.isDateInToday(date) {
            return "IS TODAY A GAMEDAY?"
        }
        return "IS \(date.mediumLabel.uppercased()) A GAMEDAY?"
    }

    var body: some View {
        VStack(spacing: 24) {
            Text(questionLabel)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(accent)
                .tracking(2)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(info.isGameday ? "YES" : "NO")
                .font(.system(size: 88, weight: .black, design: .rounded))
                .foregroundStyle(accent.opacity(info.isGameday ? 1 : 0.4))   // NO = dimmed "off" accent
                .contentTransition(.numericText())

            if info.isGameday {
                VStack(spacing: 22) {
                    ForEach(Array(info.games.enumerated()), id: \.offset) { index, game in
                        if let headline = game.matchupHeadline(for: filter) {
                            VStack(spacing: 2) {
                                // Label each leg only when it's actually a doubleheader.
                                if info.games.count > 1 {
                                    Text("GAME \(index + 1)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundStyle(accent)
                                }
                                GameDetailRow(headline: headline, gameState: game.gameState, gameTime: game.gameTime, headlineColor: accent)
                            }
                            // De-emphasize a game that has already started or ended.
                            .opacity(hasStarted(game) ? 0.5 : 1)
                        }
                    }
                }
            } else if let nextGame, let headline = nextGame.game.matchupHeadline(for: filter) {
                VStack(spacing: 2) {
                    Text("NEXT GAME")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundStyle(accent)
                    Text(nextGame.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day()))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(headline)
                        .font(.subheadline)
                        .foregroundStyle(accent)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
}

// MARK: - Previews

private func game(_ home: String, _ away: String, time: String, state: GameState = .preview) -> GameInfo {
    GameInfo(
        homeTeamId: 111, homeTeamName: home, awayTeamId: 147, awayTeamName: away,
        venueName: "Fenway Park", startDate: nil, gameTime: time, gameState: state
    )
}

#Preview("Team — single game") {
    GamedayPanel(
        info: GamedayInfo(games: [game("Boston Red Sox", "New York Yankees", time: "7:10 PM")]),
        filter: .team(.default), date: Date()
    )
}

#Preview("Venue — doubleheader") {
    GamedayPanel(
        info: GamedayInfo(games: [
            game("Boston Red Sox", "Tampa Bay Rays", time: "1:35 PM", state: .final),
            game("Boston Red Sox", "Tampa Bay Rays", time: "7:10 PM"),
        ]),
        filter: .venue(.default), date: Date()
    )
}

#Preview("No game") {
    GamedayPanel(info: .noGame, filter: .team(.default), date: Date())
}

#Preview("No game — with next game") {
    GamedayPanel(
        info: .noGame, filter: .team(.default), date: Date(),
        nextGame: UpcomingGame(
            date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!,
            game: game("Boston Red Sox", "New York Yankees", time: "7:10 PM")
        )
    )
}
