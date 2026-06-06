import WidgetKit
import SwiftUI

// Lock Screen accessory widgets are iOS-only.
#if os(iOS)
struct AccessoryRectangularView: View {
    let entry: GamedayEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(entry.filter.shortLabel.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .widgetAccentable()
                .lineLimit(1)
            Text(entry.info.isGameday ? "Gameday" : "No game")
                .font(.headline)
            if let headline = entry.info.primary?.matchupHeadline(for: entry.filter) {
                Text(headline)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(.clear, for: .widget)
    }
}
#endif
