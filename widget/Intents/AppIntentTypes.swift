import AppIntents

// AppIntents conformances live ONLY in the widget target. The underlying types
// (MLBTeam, MLBVenue, GamedayFilterKind) are declared in Shared/, but their
// AppEntity/AppEnum/EntityQuery conformances must be registered from a single
// module — otherwise the app and widget each register a duplicate entity with
// the same identifier, and widget configuration parameters fail to resolve
// (falling back to defaults).

// MARK: - MLBTeam

extension MLBTeam: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "MLB Team" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: fullName))
    }

    static var defaultQuery: MLBTeamQuery { MLBTeamQuery() }
}

struct MLBTeamQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [MLBTeam] {
        MLBTeam.all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [MLBTeam] {
        MLBTeam.all
    }

    func defaultResult() async -> MLBTeam? {
        .default
    }
}

// MARK: - MLBVenue

extension MLBVenue: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "MLB Venue" }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: LocalizedStringResource(stringLiteral: name))
    }

    static var defaultQuery: MLBVenueQuery { MLBVenueQuery() }
}

struct MLBVenueQuery: EntityQuery {
    func entities(for identifiers: [Int]) async throws -> [MLBVenue] {
        MLBVenue.all.filter { identifiers.contains($0.id) }
    }

    func suggestedEntities() async throws -> [MLBVenue] {
        MLBVenue.all
    }

    func defaultResult() async -> MLBVenue? {
        .default
    }
}

// MARK: - GamedayFilterKind

extension GamedayFilterKind: AppEnum {
    static var typeDisplayRepresentation: TypeDisplayRepresentation { "Filter By" }

    static var caseDisplayRepresentations: [GamedayFilterKind: DisplayRepresentation] {
        [.team: "Team", .venue: "Venue"]
    }
}
