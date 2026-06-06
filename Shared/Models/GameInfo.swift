import Foundation

/// Neutral facts for one game. Presentation (vs/@/matchup) is derived from these
/// by the view layer based on the active filter. Codable so it can be cached.
struct GameInfo: Sendable, Equatable, Codable {
    let homeTeamId: Int?
    let homeTeamName: String?
    let awayTeamId: Int?
    let awayTeamName: String?
    let venueName: String?
    let startDate: Date?      // exact first-pitch instant, for reminders
    let gameTime: String?     // localized short time, e.g. "7:10 PM"
    let gameState: GameState?
}

extension GameInfo {
    /// Matchup line framed for the active filter:
    /// team → "vs. Away" / "@ Home"; venue → "Away @ Home".
    func matchupHeadline(for filter: GamedayFilter) -> String? {
        guard let home = homeTeamName, let away = awayTeamName else { return nil }
        switch filter {
        case .team(let team):
            let isHome = homeTeamId == Int(team.id)
            let opponent = isHome ? "vs. \(away)" : "@ \(home)"
            guard let venueName else { return opponent }
            return "\(opponent) at \(venueName)"
        case .venue:
            return "\(away) @ \(home)"
        }
    }
}
