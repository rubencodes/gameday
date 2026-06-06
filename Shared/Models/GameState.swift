import Foundation

/// Coarse state of a game, mapped from the API's `abstractGameState`.
enum GameState: String, Codable, Sendable {
    case preview = "Preview"   // scheduled, not yet started
    case live = "Live"
    case final = "Final"
}
