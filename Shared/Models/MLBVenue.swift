import Foundation

struct MLBVenue: Codable, Identifiable, Hashable, Sendable {
    let id: Int
    let name: String
    let homeTeamId: String   // MLBTeam.id — used for venue theming

    // Fenway Park — mirrors the BOS team default.
    static let `default` = MLBVenue(id: 3, name: "Fenway Park", homeTeamId: "111")

    // Current MLB ballparks (id + name from statsapi /teams home-venue field),
    // sorted alphabetically by name for menu display.
    static let all: [MLBVenue] = [
        MLBVenue(id: 32,   name: "American Family Field",         homeTeamId: "158"), // MIL
        MLBVenue(id: 1,    name: "Angel Stadium",                 homeTeamId: "108"), // LAA
        MLBVenue(id: 2889, name: "Busch Stadium",                 homeTeamId: "138"), // STL
        MLBVenue(id: 15,   name: "Chase Field",                   homeTeamId: "109"), // AZ
        MLBVenue(id: 3289, name: "Citi Field",                    homeTeamId: "121"), // NYM
        MLBVenue(id: 2681, name: "Citizens Bank Park",            homeTeamId: "143"), // PHI
        MLBVenue(id: 2394, name: "Comerica Park",                 homeTeamId: "116"), // DET
        MLBVenue(id: 19,   name: "Coors Field",                   homeTeamId: "115"), // COL
        MLBVenue(id: 2392, name: "Daikin Park",                   homeTeamId: "117"), // HOU
        MLBVenue(id: 22,   name: "Dodger Stadium",                homeTeamId: "119"), // LAD
        MLBVenue(id: 3,    name: "Fenway Park",                   homeTeamId: "111"), // BOS
        MLBVenue(id: 2523, name: "George M. Steinbrenner Field",  homeTeamId: "139"), // TB
        MLBVenue(id: 5325, name: "Globe Life Field",              homeTeamId: "140"), // TEX
        MLBVenue(id: 2602, name: "Great American Ball Park",      homeTeamId: "113"), // CIN
        MLBVenue(id: 7,    name: "Kauffman Stadium",              homeTeamId: "118"), // KC
        MLBVenue(id: 4169, name: "loanDepot park",                homeTeamId: "146"), // MIA
        MLBVenue(id: 3309, name: "Nationals Park",                homeTeamId: "120"), // WSH
        MLBVenue(id: 2395, name: "Oracle Park",                   homeTeamId: "137"), // SF
        MLBVenue(id: 2,    name: "Oriole Park at Camden Yards",   homeTeamId: "110"), // BAL
        MLBVenue(id: 2680, name: "Petco Park",                    homeTeamId: "135"), // SD
        MLBVenue(id: 31,   name: "PNC Park",                      homeTeamId: "134"), // PIT
        MLBVenue(id: 5,    name: "Progressive Field",             homeTeamId: "114"), // CLE
        MLBVenue(id: 4,    name: "Rate Field",                    homeTeamId: "145"), // CWS
        MLBVenue(id: 14,   name: "Rogers Centre",                 homeTeamId: "141"), // TOR
        MLBVenue(id: 2529, name: "Sutter Health Park",            homeTeamId: "133"), // ATH
        MLBVenue(id: 680,  name: "T-Mobile Park",                 homeTeamId: "136"), // SEA
        MLBVenue(id: 3312, name: "Target Field",                  homeTeamId: "142"), // MIN
        MLBVenue(id: 4705, name: "Truist Park",                   homeTeamId: "144"), // ATL
        MLBVenue(id: 17,   name: "Wrigley Field",                 homeTeamId: "112"), // CHC
        MLBVenue(id: 3313, name: "Yankee Stadium",                homeTeamId: "147"), // NYY
    ]

    static func find(id: Int) -> MLBVenue? { all.first { $0.id == id } }

    /// Forgiving lookup for a spoken/typed ballpark name. Tries, in order:
    /// exact → substring (either direction, tolerates filler) → distinctive-word
    /// overlap (so "Fenway" matches "Fenway Park" but bare "park" matches nothing).
    /// Returns best candidates; the caller typically takes `.first`.
    static func search(_ query: String) -> [MLBVenue] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalizedQuery.isEmpty else { return [] }

        if let exact = all.first(where: { $0.name.lowercased() == normalizedQuery }) {
            return [exact]
        }

        let substring = all.filter {
            let name = $0.name.lowercased()
            return name.contains(normalizedQuery) || normalizedQuery.contains(name)
        }
        if !substring.isEmpty { return substring }

        let queryWords = distinctiveWords(normalizedQuery)
        guard !queryWords.isEmpty else { return [] }
        return all.filter { !distinctiveWords($0.name.lowercased()).isDisjoint(with: queryWords) }
    }

    private static func distinctiveWords(_ string: String) -> Set<String> {
        let stop: Set<String> = ["park", "stadium", "field", "ballpark", "the", "at", "of", "and", "yards"]
        let words = string.split { !$0.isLetter && !$0.isNumber }.map(String.init)
        return Set(words.filter { $0.count > 2 && !stop.contains($0) })
    }
}
