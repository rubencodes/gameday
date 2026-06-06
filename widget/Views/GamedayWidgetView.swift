import WidgetKit
import SwiftUI

struct GamedayWidgetView: View {
    let entry: GamedayEntry
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    private var accent: Color { entry.filter.theme.accent(for: colorScheme) }

    var body: some View {
        // Apply the deep link once at the top level so every family — including the
        // accessory (Lock Screen) widgets — opens the app scoped to its filter.
        content
            .widgetURL(entry.filter.deepLinkURL)
    }

    @ViewBuilder
    private var content: some View {
        switch family {
        #if os(iOS)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        #endif
        default:
            homeScreenView
        }
    }

    private var homeScreenView: some View {
        VStack(alignment: .leading, spacing: 0) {
            WidgetHeaderView(label: entry.filter.shortLabel, accent: accent)
            Spacer(minLength: 4)
            WidgetAnswerView(info: entry.info, filter: entry.filter)
            if let game = entry.info.primary {
                Spacer(minLength: 4)
                WidgetGameDetailsView(game: game, filter: entry.filter)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(for: .widget) {
            Rectangle().fill(.background)
                .overlay(entry.filter.theme.backgroundGradient)
        }
    }
}
