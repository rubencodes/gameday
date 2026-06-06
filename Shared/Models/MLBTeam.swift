import Foundation

struct MLBTeam: Codable, Identifiable, Hashable, Sendable {
    let id: String
    let abbreviation: String
    let fullName: String

    // Used as fallback when no team is configured
    static let `default` = MLBTeam(id: "111", abbreviation: "BOS", fullName: "Boston Red Sox")

    // Source of truth: statsapi /teams?sportId=1 (id, abbreviation, name). Sorted by id.
    static let all: [MLBTeam] = [
        MLBTeam(id: "108", abbreviation: "LAA", fullName: "Los Angeles Angels"),
        MLBTeam(id: "109", abbreviation: "AZ",  fullName: "Arizona Diamondbacks"),
        MLBTeam(id: "110", abbreviation: "BAL", fullName: "Baltimore Orioles"),
        MLBTeam(id: "111", abbreviation: "BOS", fullName: "Boston Red Sox"),
        MLBTeam(id: "112", abbreviation: "CHC", fullName: "Chicago Cubs"),
        MLBTeam(id: "113", abbreviation: "CIN", fullName: "Cincinnati Reds"),
        MLBTeam(id: "114", abbreviation: "CLE", fullName: "Cleveland Guardians"),
        MLBTeam(id: "115", abbreviation: "COL", fullName: "Colorado Rockies"),
        MLBTeam(id: "116", abbreviation: "DET", fullName: "Detroit Tigers"),
        MLBTeam(id: "117", abbreviation: "HOU", fullName: "Houston Astros"),
        MLBTeam(id: "118", abbreviation: "KC",  fullName: "Kansas City Royals"),
        MLBTeam(id: "119", abbreviation: "LAD", fullName: "Los Angeles Dodgers"),
        MLBTeam(id: "120", abbreviation: "WSH", fullName: "Washington Nationals"),
        MLBTeam(id: "121", abbreviation: "NYM", fullName: "New York Mets"),
        MLBTeam(id: "133", abbreviation: "ATH", fullName: "Athletics"),
        MLBTeam(id: "134", abbreviation: "PIT", fullName: "Pittsburgh Pirates"),
        MLBTeam(id: "135", abbreviation: "SD",  fullName: "San Diego Padres"),
        MLBTeam(id: "136", abbreviation: "SEA", fullName: "Seattle Mariners"),
        MLBTeam(id: "137", abbreviation: "SF",  fullName: "San Francisco Giants"),
        MLBTeam(id: "138", abbreviation: "STL", fullName: "St. Louis Cardinals"),
        MLBTeam(id: "139", abbreviation: "TB",  fullName: "Tampa Bay Rays"),
        MLBTeam(id: "140", abbreviation: "TEX", fullName: "Texas Rangers"),
        MLBTeam(id: "141", abbreviation: "TOR", fullName: "Toronto Blue Jays"),
        MLBTeam(id: "142", abbreviation: "MIN", fullName: "Minnesota Twins"),
        MLBTeam(id: "143", abbreviation: "PHI", fullName: "Philadelphia Phillies"),
        MLBTeam(id: "144", abbreviation: "ATL", fullName: "Atlanta Braves"),
        MLBTeam(id: "145", abbreviation: "CWS", fullName: "Chicago White Sox"),
        MLBTeam(id: "146", abbreviation: "MIA", fullName: "Miami Marlins"),
        MLBTeam(id: "147", abbreviation: "NYY", fullName: "New York Yankees"),
        MLBTeam(id: "158", abbreviation: "MIL", fullName: "Milwaukee Brewers"),
    ]

    static func find(id: String) -> MLBTeam? { all.first { $0.id == id } }
}
