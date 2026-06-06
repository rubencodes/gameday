import Foundation
import SwiftData
import SwiftUI

enum ViewState {
    case loading
    case loaded(GamedayInfo)
    case unavailable
    case error
}

@MainActor
@Observable
final class GamedayViewModel {
    var viewState: ViewState = .loading
    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var nextGame: UpcomingGame?

    var isToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }

    var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        return today...Calendar.current.date(byAdding: .year, value: 1, to: today)!
    }

    func taskId(filterId: String) -> String {
        "\(filterId)_\(selectedDate.scheduleKey)"
    }

    // MARK: - Loading

    /// Stale-while-revalidate: show any cached result instantly, then refetch and
    /// update. Cached entries never expire on their own, so always revalidating is
    /// what keeps a once-cached wrong/empty answer from sticking. If revalidation
    /// fails (e.g. offline), we keep showing the stale data instead of erroring —
    /// we only surface an error/unavailable state when there's nothing cached.
    func load(
        filter: GamedayFilter,
        cache: [GamedayCache],
        in context: ModelContext
    ) async {
        let dateKey = selectedDate.scheduleKey
        nextGame = nil

        let staleEntry = cached(filter: filter, date: dateKey, in: cache)
        if let staleEntry {
            withAnimation { viewState = .loaded(staleEntry.info) }
        } else {
            viewState = .loading
        }

        do {
            let info = try await MLBService.fetchGameday(filter: filter, on: selectedDate)
            upsert(info: info, filter: filter, date: dateKey, cache: cache, in: context)
            withAnimation { viewState = .loaded(info) }
            await loadNextGameIfNeeded(info, filter: filter)
        } catch MLBServiceError.unavailable {
            if staleEntry == nil { withAnimation { viewState = .unavailable } }
        } catch {
            // Network/offline failure — keep the stale data we're already showing.
            if staleEntry == nil { withAnimation { viewState = .error } }
        }
    }

    /// When the selected date has no game, surface the next one within the look-ahead
    /// window. Failures here are non-fatal — we just don't show the line.
    private func loadNextGameIfNeeded(_ info: GamedayInfo, filter: GamedayFilter) async {
        guard !info.isGameday else { return }
        let upcoming = try? await MLBService.fetchNextGame(filter: filter, after: selectedDate)
        withAnimation { nextGame = upcoming }
    }

    // MARK: - Cache

    private func cached(filter: GamedayFilter, date: String, in cache: [GamedayCache]) -> GamedayCache? {
        cache.first { $0.filterId == filter.id && $0.date == date }
    }

    private func upsert(
        info: GamedayInfo,
        filter: GamedayFilter,
        date: String,
        cache: [GamedayCache],
        in context: ModelContext
    ) {
        if let entry = cached(filter: filter, date: date, in: cache) {
            entry.apply(info)
        } else {
            context.insert(GamedayCache(filterId: filter.id, date: date, info: info))
        }
    }
}
