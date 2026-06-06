import Foundation

enum MLBServiceError: Error {
    case unavailable  // API responded but returned no schedule data for this date
}

enum MLBService {
    /// Games for the filter on a single date (0, 1, or — for doubleheaders — more).
    static func fetchGameday(filter: GamedayFilter, on date: Date = .init()) async throws -> GamedayInfo {
        let dates = try await fetchSchedule(filter: filter, start: date, end: date)
        return GamedayInfo(games: (dates.first?.games ?? []).map(Self.gameInfo))
    }

    /// The next game within a bounded look-ahead window (default 14 days), or nil if
    /// none is scheduled in that window. Bounded so we never chase a game months away.
    static func fetchNextGame(
        filter: GamedayFilter,
        after date: Date = .init(),
        withinDays days: Int = 14
    ) async throws -> UpcomingGame? {
        let calendar = Calendar.current
        let start = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date))!
        let end = calendar.date(byAdding: .day, value: days, to: start)!

        let dates = try await fetchSchedule(filter: filter, start: start, end: end)
        // `dates` is chronological; the first entry with a game is the next game.
        for scheduleDate in dates {
            if let game = scheduleDate.games.first {
                let day = scheduleDate.date.scheduleDate ?? start
                return UpcomingGame(date: day, game: gameInfo(from: game))
            }
        }
        return nil
    }

    // MARK: - Shared request

    private static func fetchSchedule(
        filter: GamedayFilter,
        start: Date,
        end: Date
    ) async throws -> [MLBScheduleResponse.ScheduleDate] {
        let urlString = "https://statsapi.mlb.com/api/v1/schedule"
            + "?hydrate=team&sportId=1"
            + "&startDate=\(start.scheduleKey)&endDate=\(end.scheduleKey)"
            + "&\(filter.queryItem)"

        guard let url = URL(string: urlString) else { throw URLError(.badURL) }

        // Bound the request so a widget timeline can never hang indefinitely.
        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(MLBScheduleResponse.self, from: data)

        // A missing `dates` key means the response wasn't in the shape we expect.
        guard let dates = response.dates else {
            throw MLBServiceError.unavailable
        }
        return dates
    }

    // MARK: - Mapping

    private static func gameInfo(from game: MLBScheduleResponse.Game) -> GameInfo {
        let start = iso8601.date(from: game.gameDate)
        return GameInfo(
            homeTeamId: game.teams.home.team.id,
            homeTeamName: game.teams.home.team.name,
            awayTeamId: game.teams.away.team.id,
            awayTeamName: game.teams.away.team.name,
            venueName: game.venue?.name,
            startDate: start,
            gameTime: start.map { shortTimeFormatter.string(from: $0) },
            gameState: GameState(rawValue: game.status.abstractGameState)
        )
    }

    // Cached formatters — reused across calls instead of re-allocated per game.
    private static let iso8601 = ISO8601DateFormatter()

    private static let shortTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        formatter.timeZone = .current
        return formatter
    }()
}
