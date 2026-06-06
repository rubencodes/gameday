import Foundation

/// The single, mutually-exclusive thing the user is looking at: either a team or a venue.
enum GamedayFilter: Hashable, Sendable {
    case team(MLBTeam)
    case venue(MLBVenue)

    /// Stable key used for cache lookups and `.task(id:)` invalidation.
    var id: String {
        switch self {
        case .team(let team): return "team:\(team.id)"
        case .venue(let venue): return "venue:\(venue.id)"
        }
    }

    /// Inverse of `id` — resolve a stored key back into a filter, or nil if it
    /// references a team/venue that no longer exists.
    init?(id: String) {
        let parts = id.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        switch parts[0] {
        case "team":
            guard let team = MLBTeam.find(id: String(parts[1])) else { return nil }
            self = .team(team)
        case "venue":
            guard let venueId = Int(parts[1]), let venue = MLBVenue.find(id: venueId) else { return nil }
            self = .venue(venue)
        default:
            return nil
        }
    }

    /// Navigation title.
    var title: String {
        switch self {
        case .team(let team): return team.fullName
        case .venue(let venue): return venue.name
        }
    }

    /// SF Symbol shown in the picker.
    var iconName: String {
        switch self {
        case .team: return "baseball.fill"
        case .venue: return "mappin.and.ellipse"
        }
    }

    /// Compact label for tight spaces (e.g. the widget header).
    var shortLabel: String {
        switch self {
        case .team(let team): return team.abbreviation
        case .venue(let venue): return venue.name
        }
    }

    /// The schedule-endpoint query item that scopes results to this filter.
    var queryItem: String {
        switch self {
        case .team(let team): return "teamId=\(team.id)"
        case .venue(let venue): return "venueIds=\(venue.id)"
        }
    }

    /// Color theme — a team's own palette, or a venue's home-team palette.
    var theme: Theme {
        switch self {
        case .team(let team): return .team(team.id)
        case .venue(let venue): return .team(venue.homeTeamId)
        }
    }
}

// MARK: - Deep linking

extension GamedayFilter {
    static let deepLinkScheme = "gameday"

    /// URL the widget hands to `widgetURL` so a tap opens the app scoped to this filter.
    var deepLinkURL: URL {
        switch self {
        case .team(let team):
            return URL(string: "\(Self.deepLinkScheme)://filter?kind=team&id=\(team.id)")!
        case .venue(let venue):
            return URL(string: "\(Self.deepLinkScheme)://filter?kind=venue&id=\(venue.id)")!
        }
    }

    /// Decoded parts of a gameday deep link, or nil if the URL isn't ours.
    struct DeepLink {
        let kind: GamedayFilterKind
        let teamId: String?
        let venueId: Int?
    }

    static func decodeDeepLink(_ url: URL) -> DeepLink? {
        guard url.scheme == deepLinkScheme,
              let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let kindRaw = items.first(where: { $0.name == "kind" })?.value,
              let kind = GamedayFilterKind(rawValue: kindRaw) else { return nil }

        let id = items.first(where: { $0.name == "id" })?.value
        switch kind {
        case .team: return DeepLink(kind: .team, teamId: id, venueId: nil)
        case .venue: return DeepLink(kind: .venue, teamId: nil, venueId: id.flatMap(Int.init))
        }
    }
}
