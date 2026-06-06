import AppIntents

/// Exposes the gameday check to Siri and the Shortcuts app with zero setup.
struct GamedayShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckGamedayIntent(),
            phrases: [
                "Is there a game today in \(.applicationName)",
                "Check for a game today in \(.applicationName)",
                "Ask \(.applicationName) if there's a game today",
            ],
            shortTitle: "Check Gameday",
            systemImageName: "baseball"
        )
    }
}
