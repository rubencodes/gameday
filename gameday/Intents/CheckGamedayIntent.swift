import AppIntents

/// "Is there a game today at <ballpark>?" — takes the ballpark as a spoken/typed
/// string and resolves it ourselves, rather than as an AppEntity. Siri's entity
/// disambiguation over 30 venues falls back to a pick-list and ignores the spoken
/// value; a plain String lets us match the dictation directly and reliably.
struct CheckGamedayIntent: AppIntent {
    static var title: LocalizedStringResource { "Check Gameday at Ballpark" }
    static var description: IntentDescription {
        IntentDescription("Find out whether there's a game today at a ballpark.")
    }

    // Runs in the background and just speaks the result — no need to open the app.
    static var openAppWhenRun: Bool { false }

    @Parameter(title: "Ballpark", requestValueDialog: "Which ballpark?")
    var ballpark: String

    static var parameterSummary: some ParameterSummary {
        Summary("Is there a game today at \(\.$ballpark)?")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let venue = try await resolvedVenue()

        let info: GamedayInfo
        do {
            info = try await MLBService.fetchGameday(filter: .venue(venue))
        } catch {
            return .result(dialog: "Sorry, I couldn't check the schedule for \(venue.name) right now.")
        }

        guard let game = info.primary else {
            return .result(dialog: IntentDialog(stringLiteral: "No, there's no game today at \(venue.name)."))
        }

        var line = "Yes, there's a game today at \(venue.name)"
        if let away = game.awayTeamName, let home = game.homeTeamName {
            line = "Yes — \(away) at \(home) today at \(venue.name)"
        }
        if let time = game.gameTime {
            line += ", first pitch \(time)"
        }
        line += "."
        return .result(dialog: IntentDialog(stringLiteral: line))
    }

    /// Resolve the spoken/typed ballpark, falling back to a pick-list when the
    /// input is ambiguous (several matches) or unrecognized (no matches).
    private func resolvedVenue() async throws -> MLBVenue {
        let matches = MLBVenue.search(ballpark)
        switch matches.count {
        case 1:
            return matches[0]
        case 0:
            let chosen = try await $ballpark.requestDisambiguation(
                among: MLBVenue.all.map(\.name),
                dialog: "I couldn't find a ballpark called \(ballpark). Which one?"
            )
            return MLBVenue.all.first { $0.name == chosen } ?? .default
        default:
            let chosen = try await $ballpark.requestDisambiguation(
                among: matches.map(\.name),
                dialog: "Which ballpark did you mean?"
            )
            return MLBVenue.all.first { $0.name == chosen } ?? .default
        }
    }
}
