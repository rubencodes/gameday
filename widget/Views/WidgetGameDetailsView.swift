import SwiftUI

struct WidgetGameDetailsView: View {
    let game: GameInfo
    let filter: GamedayFilter
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let headline = game.matchupHeadline(for: filter) {
                Text(headline)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(filter.theme.accent(for: colorScheme))
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            if let time = game.gameTime {
                Text(game.gameState == .live ? "NOW PLAYING" : time)
                    .font(.caption2)
                    .foregroundStyle(game.gameState == .live ? Color.red : Color.secondary)
            }
        }
    }
}
