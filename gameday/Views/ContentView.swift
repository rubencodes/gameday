import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var cache: [GamedayCache]

    @AppStorage("filterKind") private var filterKindRaw: String = GamedayFilterKind.team.rawValue
    @AppStorage("selectedTeamId") private var selectedTeamId: String = MLBTeam.default.id
    @AppStorage("selectedVenueId") private var selectedVenueId: Int = MLBVenue.default.id

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    @State private var viewModel = GamedayViewModel()
    @State private var favorites = FavoritesStore()
    @State private var notifications = NotificationManager()
    @State private var isDatePickerPresented = false

    private var filter: GamedayFilter {
        switch GamedayFilterKind(rawValue: filterKindRaw) ?? .team {
        case .team: return .team(MLBTeam.find(id: selectedTeamId) ?? .default)
        case .venue: return .venue(MLBVenue.find(id: selectedVenueId) ?? .default)
        }
    }

    private var theme: Theme { filter.theme }

    /// The soonest game on the selected day whose first pitch is still ahead — the
    /// one a reminder would apply to. nil when there's nothing upcoming to remind for.
    private var remindableGame: GameInfo? {
        guard case .loaded(let info) = viewModel.viewState else { return nil }
        return info.games.first { ($0.startDate ?? .distantPast) > Date() }
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .loading:
                    LoadingView()
                case .loaded(let info):
                    GamedayPanel(info: info, filter: filter, date: viewModel.selectedDate, nextGame: viewModel.nextGame)
                case .unavailable:
                    UnavailableView(date: viewModel.selectedDate)
                case .error:
                    ErrorView {
                        await viewModel.load(filter: filter, cache: cache, in: modelContext)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.backgroundGradient.ignoresSafeArea())
            .tint(theme.accent(for: colorScheme))
            .navigationTitle(filter.title)
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .gamedayTrailing) {
                    FilterPickerMenu(
                        selection: filter,
                        favorites: favorites.filters,
                        onSelectTeam: { team in
                            filterKindRaw = GamedayFilterKind.team.rawValue
                            selectedTeamId = team.id
                        },
                        onSelectVenue: { venue in
                            filterKindRaw = GamedayFilterKind.venue.rawValue
                            selectedVenueId = venue.id
                        }
                    )
                    // Top-bar items don't inherit the ambient .tint on iOS 18; set it explicitly.
                    .tint(theme.accent(for: colorScheme))
                }
                ToolbarItem(placement: .gamedayLeading) {
                    Button {
                        favorites.toggle(filter)
                    } label: {
                        Label(
                            favorites.isFavorite(filter) ? "Remove favorite" : "Add favorite",
                            systemImage: favorites.isFavorite(filter) ? "star.fill" : "star"
                        )
                    }
                    .tint(theme.accent(for: colorScheme))
                }
                // Leading group: reminder bell, then a flexible spacer pushing the
                // date controls to the trailing edge.
                ToolbarItemGroup(placement: .gamedayDateControls) {
                    if let game = remindableGame {
                        ReminderButton(game: game, filter: filter, manager: notifications)
                            .tint(theme.accent(for: colorScheme))
                            .transition(.opacity.combined(with: .scale))
                    }
                    Spacer()
                    if !viewModel.isToday {
                        Button {
                            withAnimation { viewModel.selectedDate = Calendar.current.startOfDay(for: Date()) }
                        } label: {
                            // Explicit HStack: a Label gets collapsed to icon-only by the
                            // toolbar's environment, so we lay out icon + text ourselves.
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Today")
                            }
                            .font(.callout)
                        }
                        .tint(theme.accent(for: colorScheme))
                        .transition(.opacity.combined(with: .scale))
                    }
                }

                // Separate trailing group so the calendar reads as its own distinct,
                // prominent control rather than merging with the "Today" shortcut.
                ToolbarItem(placement: .gamedayDateControls) {
                    Button { isDatePickerPresented = true } label: {
                        Label(
                            viewModel.selectedDate.mediumLabel,
                            systemImage: "calendar"
                        )
                        .font(.callout.weight(.semibold))
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .tint(theme.accent(for: colorScheme))   // borderedProminent in .bottomBar doesn't inherit ambient tint
                }
            }
            .sheet(isPresented: $isDatePickerPresented) {
                DatePickerSheet(viewModel: viewModel, isPresented: $isDatePickerPresented)
            }
            .task(id: viewModel.taskId(filterId: filter.id)) {
                await viewModel.load(filter: filter, cache: cache, in: modelContext)
            }
            .onOpenURL { url in
                guard let link = GamedayFilter.decodeDeepLink(url) else { return }
                filterKindRaw = link.kind.rawValue
                if let teamId = link.teamId { selectedTeamId = teamId }
                if let venueId = link.venueId { selectedVenueId = venueId }
            }
            .adaptiveFullScreenCover(isPresented: .init(
                get: { !hasCompletedOnboarding },
                set: { hasCompletedOnboarding = !$0 }
            )) {
                OnboardingView(
                    filterKindRaw: $filterKindRaw,
                    selectedTeamId: $selectedTeamId,
                    selectedVenueId: $selectedVenueId,
                    notifications: notifications,
                    onFinish: {
                        // Auto-favorite the team/venue chosen during onboarding.
                        favorites.favorite(filter)
                        hasCompletedOnboarding = true
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: GamedayCache.self, inMemory: true)
}
