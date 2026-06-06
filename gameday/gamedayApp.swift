import SwiftUI
import SwiftData

@main
struct gamedayApp: App {
    let container: ModelContainer = Self.makeContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }

    /// The cache is disposable, so if the persisted store can't be opened
    /// (e.g. after a schema change) we wipe it and retry rather than crash.
    private static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: GamedayCache.self)
        } catch {
            let dir = URL.applicationSupportDirectory
            for name in ["default.store", "default.store-shm", "default.store-wal"] {
                try? FileManager.default.removeItem(at: dir.appending(path: name))
            }
            return try! ModelContainer(for: GamedayCache.self)
        }
    }
}
