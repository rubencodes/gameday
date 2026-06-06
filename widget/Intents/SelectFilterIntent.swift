import AppIntents
import WidgetKit

struct SelectFilterIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Team or Venue"
    static var description = IntentDescription("Track gameday for an MLB team or ballpark.")

    @Parameter(title: "Filter By", default: .team)
    var filterKind: GamedayFilterKind

    @Parameter(title: "Team")
    var team: MLBTeam?

    @Parameter(title: "Venue")
    var venue: MLBVenue?

    static var parameterSummary: some ParameterSummary {
        Switch(\.$filterKind) {
            Case(.venue) {
                // The switch subject (`filterKind`) must appear here, or the
                // "Filter By" toggle won't render and the user can't reach venues.
                Summary {
                    \.$filterKind
                    \.$venue
                }
            }
            DefaultCase {
                Summary {
                    \.$filterKind
                    \.$team
                }
            }
        }
    }

    /// Resolve the configured parameters into the shared filter type.
    var gamedayFilter: GamedayFilter {
        switch filterKind {
        case .team: return .team(team ?? .default)
        case .venue: return .venue(venue ?? .default)
        }
    }
}
