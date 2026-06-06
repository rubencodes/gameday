import WidgetKit
import SwiftUI

// Lock Screen accessory widgets are iOS-only.
#if os(iOS)
struct AccessoryCircularView: View {
    let entry: GamedayEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 0) {
                Image(systemName: "baseball.fill")
                    .font(.system(size: 11))
                Text(entry.info.isGameday ? "YES" : "NO")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .minimumScaleFactor(0.6)
            }
        }
        .containerBackground(.clear, for: .widget)
    }
}
#endif
