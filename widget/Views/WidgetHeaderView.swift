import SwiftUI

struct WidgetHeaderView: View {
    let label: String
    let accent: Color

    var body: some View {
        Text(label)
            .font(.caption2)
            .fontWeight(.bold)
            .foregroundStyle(accent)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
    }
}
