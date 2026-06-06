import SwiftUI

struct FilterPickerMenu: View {
    let selection: GamedayFilter
    let favorites: [GamedayFilter]
    let onSelectTeam: (MLBTeam) -> Void
    let onSelectVenue: (MLBVenue) -> Void

    var body: some View {
        Menu {
            if !favorites.isEmpty {
                Section("Favorites") {
                    ForEach(favorites, id: \.id) { favorite in
                        Button {
                            select(favorite)
                        } label: {
                            menuLabel(favorite.title, isSelected: favorite == selection)
                        }
                    }
                }
            }

            Menu("Teams") {
                ForEach(MLBTeam.all) { team in
                    Button {
                        onSelectTeam(team)
                    } label: {
                        menuLabel(team.fullName, isSelected: isSelectedTeam(team))
                    }
                }
            }

            Menu("Venues") {
                ForEach(MLBVenue.all) { venue in
                    Button {
                        onSelectVenue(venue)
                    } label: {
                        menuLabel(venue.name, isSelected: isSelectedVenue(venue))
                    }
                }
            }
        } label: {
            Label("Choose team or venue", systemImage: selection.iconName)
        }
    }

    private func select(_ filter: GamedayFilter) {
        switch filter {
        case .team(let team): onSelectTeam(team)
        case .venue(let venue): onSelectVenue(venue)
        }
    }

    @ViewBuilder
    private func menuLabel(_ title: String, isSelected: Bool) -> some View {
        if isSelected {
            Label(title, systemImage: "checkmark")
        } else {
            Text(title)
        }
    }

    private func isSelectedTeam(_ team: MLBTeam) -> Bool {
        if case .team(let selected) = selection { return selected.id == team.id }
        return false
    }

    private func isSelectedVenue(_ venue: MLBVenue) -> Bool {
        if case .venue(let selected) = selection { return selected.id == venue.id }
        return false
    }
}

#Preview("With favorites") {
    FilterPickerMenu(
        selection: .team(.default),
        favorites: [.team(.default), .venue(.default)],
        onSelectTeam: { _ in },
        onSelectVenue: { _ in }
    )
}
