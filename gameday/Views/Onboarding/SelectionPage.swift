import SwiftUI

struct SelectionPage: View {
    @Binding var filterKindRaw: String
    @Binding var selectedTeamId: String
    @Binding var selectedVenueId: Int

    private var kind: GamedayFilterKind {
        GamedayFilterKind(rawValue: filterKindRaw) ?? .team
    }

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 6) {
                Text("What's your favorite?")
                    .font(.title.bold())
                Text("You can follow more teams and ballparks anytime.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Picker("Filter By", selection: Binding(
                get: { kind },
                set: { filterKindRaw = $0.rawValue }
            )) {
                Text("Team").tag(GamedayFilterKind.team)
                Text("Venue").tag(GamedayFilterKind.venue)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)

            switch kind {
            case .team:
                Picker("Team", selection: $selectedTeamId) {
                    ForEach(MLBTeam.all) { team in
                        Text(team.fullName).tag(team.id)
                    }
                }
                .longListPickerStyle()
            case .venue:
                Picker("Venue", selection: $selectedVenueId) {
                    ForEach(MLBVenue.all) { venue in
                        Text(venue.name).tag(venue.id)
                    }
                }
                .longListPickerStyle()
            }
        }
        .padding(.vertical, 40)
    }
}
