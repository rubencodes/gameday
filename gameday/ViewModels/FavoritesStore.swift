import Foundation

/// Persists the user's favorited filters (teams and venues) as a list of
/// `GamedayFilter.id` strings in UserDefaults.
@MainActor
@Observable
final class FavoritesStore {
    private static let key = "favoriteFilterIds"
    private let defaults: UserDefaults

    private(set) var ids: [String]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.ids = defaults.stringArray(forKey: Self.key) ?? []
    }

    func isFavorite(_ filter: GamedayFilter) -> Bool {
        ids.contains(filter.id)
    }

    func toggle(_ filter: GamedayFilter) {
        if let index = ids.firstIndex(of: filter.id) {
            ids.remove(at: index)
        } else {
            ids.append(filter.id)
        }
        defaults.set(ids, forKey: Self.key)
    }

    /// Adds a favorite if not already present (idempotent — won't toggle off).
    func favorite(_ filter: GamedayFilter) {
        guard !ids.contains(filter.id) else { return }
        ids.append(filter.id)
        defaults.set(ids, forKey: Self.key)
    }

    /// Favorites resolved back into filters, preserving insertion order and
    /// dropping any that no longer resolve (e.g. a removed team/venue).
    var filters: [GamedayFilter] {
        ids.compactMap(GamedayFilter.init(id:))
    }
}
