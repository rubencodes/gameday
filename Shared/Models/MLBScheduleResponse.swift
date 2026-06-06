import Foundation

struct MLBScheduleResponse: Codable {
    // Optional so we can tell apart a non-standard response (key absent → nil → unavailable)
    // from a normal off day (key present but empty → no game).
    let dates: [ScheduleDate]?

    struct ScheduleDate: Codable {
        let date: String
        let games: [Game]
    }

    struct Game: Codable {
        let gameDate: String   // ISO 8601 UTC, e.g. "2025-09-29T23:10:00Z"
        let status: GameStatus
        let teams: GameTeams
        let venue: Venue?

        struct GameStatus: Codable {
            let abstractGameState: String  // "Preview", "Live", "Final"
        }

        struct Venue: Codable {
            let id: Int
            let name: String
        }

        struct GameTeams: Codable {
            let away: Side
            let home: Side

            struct Side: Codable {
                let team: TeamInfo

                struct TeamInfo: Codable {
                    let id: Int
                    let name: String
                }
            }
        }
    }
}
