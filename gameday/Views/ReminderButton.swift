import SwiftUI

/// Toolbar toggle for a local reminder on a single game. The parent decides when
/// to show it (i.e. only for a game whose first pitch is still in the future).
struct ReminderButton: View {
    let game: GameInfo
    let filter: GamedayFilter
    let manager: NotificationManager

    @State private var isOn = false
    @State private var busy = false

    var body: some View {
        Button {
            toggle()
        } label: {
            Label(isOn ? "Cancel game reminder" : "Remind me before this game",
                  systemImage: isOn ? "bell.fill" : "bell")
        }
        .disabled(busy)
        .task(id: game.startDate) {
            isOn = await manager.hasReminder(for: game, filter: filter)
        }
    }

    private func toggle() {
        busy = true
        Task {
            if isOn {
                manager.cancelReminder(for: game, filter: filter)
                isOn = false
            } else {
                isOn = await manager.scheduleReminder(for: game, filter: filter)
            }
            busy = false
        }
    }
}
