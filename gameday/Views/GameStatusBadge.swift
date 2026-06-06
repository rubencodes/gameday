import SwiftUI

struct GameStatusBadge: View {
    let gameState: GameState?
    let gameTime: String?

    var body: some View {
        if let time = gameTime {
            HStack(spacing: 4) {
                switch gameState {
                case .live:
                    Circle().fill(.red).frame(width: 7, height: 7)
                    Text("LIVE").foregroundStyle(.red)
                case .final:
                    Text("Final · \(time)").foregroundStyle(.secondary)
                default:
                    Text(time).foregroundStyle(.secondary)
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
        }
    }
}

#Preview("Scheduled") {
    GameStatusBadge(gameState: .preview, gameTime: "7:10 PM")
}

#Preview("Live") {
    GameStatusBadge(gameState: .live, gameTime: "7:10 PM")
}

#Preview("Final") {
    GameStatusBadge(gameState: .final, gameTime: "7:10 PM")
}
