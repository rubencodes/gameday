import WidgetKit

struct GamedayProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> GamedayEntry {
        GamedayEntry(date: .now, filter: .team(.default), info: .gamedayPreview)
    }

    func snapshot(for configuration: SelectFilterIntent, in context: Context) async -> GamedayEntry {
        let filter = configuration.gamedayFilter
        // Gallery preview can be static; a real placed widget should reflect its filter.
        if context.isPreview {
            return GamedayEntry(date: .now, filter: filter, info: .gamedayPreview)
        }
        let info = (try? await MLBService.fetchGameday(filter: filter)) ?? .noGame
        return GamedayEntry(date: .now, filter: filter, info: info)
    }

    func timeline(for configuration: SelectFilterIntent, in context: Context) async -> Timeline<GamedayEntry> {
        let filter = configuration.gamedayFilter
        let info = (try? await MLBService.fetchGameday(filter: filter)) ?? .noGame

        // Refresh once after midnight so "today" stays correct.
        let nextMidnight = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        return Timeline(entries: [GamedayEntry(date: .now, filter: filter, info: info)], policy: .after(nextMidnight))
    }
}
