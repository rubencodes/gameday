import SwiftUI

struct NotificationsPage: View {
    let notifications: NotificationManager
    @State private var requested = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Game reminders")
                .font(.title.bold())
            Text("Get a heads-up an hour before first pitch. You can turn this on per game anytime.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)

            Button(requested ? "Notifications Set Up" : "Enable Notifications") {
                requested = true
                Task { await notifications.requestAuthorization() }
            }
            .buttonStyle(.bordered)
            .disabled(requested)
        }
        .padding(40)
    }
}
