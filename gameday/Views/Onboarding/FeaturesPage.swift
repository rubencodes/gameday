import SwiftUI

struct FeaturesPage: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            featureRow("baseball.fill", "Team or ballpark", "Track a team's schedule, or any game at a venue.")
            featureRow("calendar", "Any day", "Check today, or look ahead up to a year.")
            featureRow("apps.iphone", "Widgets", "Home Screen and Lock Screen widgets at a glance.")
            featureRow("bell.fill", "Reminders", "Get notified before first pitch.")
        }
        .padding(40)
    }

    private func featureRow(_ symbol: String, _ title: String, _ subtitle: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: symbol)
                .font(.title)
                .frame(width: 44)
                .foregroundStyle(.tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
        }
    }
}
