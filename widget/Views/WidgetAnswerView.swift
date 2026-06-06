import WidgetKit
import SwiftUI

struct WidgetAnswerView: View {
    let info: GamedayInfo
    let filter: GamedayFilter
    @Environment(\.widgetFamily) private var family
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("GAMEDAY?")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(filter.theme.accent(for: colorScheme))
                .tracking(1)
            Text(info.isGameday ? "YES" : "NO")
                .font(.system(size: family == .systemSmall ? 44 : 52, weight: .black, design: .rounded))
                .foregroundStyle(filter.theme.accent(for: colorScheme).opacity(info.isGameday ? 1 : 0.4))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
    }
}
