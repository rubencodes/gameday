import SwiftUI

struct GameDetailRow: View {
    let headline: String      // "vs. Yankees" (team) or "Yankees @ Red Sox" (venue)
    let gameState: GameState?
    let gameTime: String?
    var headlineColor: Color = .primary

    var body: some View {
        VStack(spacing: 6) {
            Text(headline)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(headlineColor)
                .multilineTextAlignment(.center)

            GameStatusBadge(gameState: gameState, gameTime: gameTime)
        }
    }
}

#Preview("Team — home") {
    GameDetailRow(headline: "vs. New York Yankees", gameState: .preview, gameTime: "7:10 PM")
}

#Preview("Venue — matchup, live") {
    GameDetailRow(headline: "Tampa Bay Rays @ Boston Red Sox", gameState: .live, gameTime: "1:35 PM")
}

#Preview("Final") {
    GameDetailRow(headline: "@ Toronto Blue Jays", gameState: .final, gameTime: "4:05 PM")
}
