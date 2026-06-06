import WidgetKit
import SwiftUI

struct GamedayWidget: Widget {
    let kind = "GamedayWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: SelectFilterIntent.self, provider: GamedayProvider()) { entry in
            GamedayWidgetView(entry: entry)
        }
        .configurationDisplayName("gameday")
        .description("Know if your team or ballpark has a game today.")
        .supportedFamilies(supportedFamilies)
        .promptsForUserConfigurationIfAvailable()
    }

    // Lock Screen accessory families exist only on iOS; macOS/visionOS get system sizes.
    private var supportedFamilies: [WidgetFamily] {
        #if os(iOS)
        [.systemSmall, .systemMedium, .accessoryInline, .accessoryCircular, .accessoryRectangular]
        #else
        [.systemSmall, .systemMedium]
        #endif
    }
}

private extension WidgetConfiguration {
    /// Auto-presents the configuration UI right after the widget is added.
    /// `promptsForUserConfiguration()` is iOS 18+, so no-op on earlier versions.
    func promptsForUserConfigurationIfAvailable() -> some WidgetConfiguration {
        if #available(iOS 18.0, *) {
            return promptsForUserConfiguration()
        } else {
            return self
        }
    }
}

// MARK: - Previews

#Preview("Team — gameday", as: .systemSmall) {
    GamedayWidget()
} timeline: {
    GamedayEntry(date: .now, filter: .team(.default), info: .gamedayPreview)
    GamedayEntry(date: .now, filter: .team(.default), info: .noGame)
}

#Preview("Venue — gameday", as: .systemMedium) {
    GamedayWidget()
} timeline: {
    GamedayEntry(date: .now, filter: .venue(.default), info: .gamedayPreview)
}

#if os(iOS)
#Preview("Lock — circular", as: .accessoryCircular) {
    GamedayWidget()
} timeline: {
    GamedayEntry(date: .now, filter: .team(.default), info: .gamedayPreview)
    GamedayEntry(date: .now, filter: .team(.default), info: .noGame)
}

#Preview("Lock — rectangular", as: .accessoryRectangular) {
    GamedayWidget()
} timeline: {
    GamedayEntry(date: .now, filter: .team(.default), info: .gamedayPreview)
}

#Preview("Lock — inline", as: .accessoryInline) {
    GamedayWidget()
} timeline: {
    GamedayEntry(date: .now, filter: .team(.default), info: .gamedayPreview)
}
#endif
