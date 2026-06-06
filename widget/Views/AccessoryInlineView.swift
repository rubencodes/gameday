import SwiftUI

// Lock Screen accessory widgets are iOS-only.
#if os(iOS)
struct AccessoryInlineView: View {
    let entry: GamedayEntry

    var body: some View {
        // Inline is a single line: SF Symbol + short text.
        Label(entry.info.isGameday ? "Gameday" : "No game", systemImage: "baseball.fill")
    }
}
#endif
