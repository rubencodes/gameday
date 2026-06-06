import SwiftUI

extension Color {
    /// Create a color from a "#RRGGBB" (or "RRGGBB") hex string, optionally mixed
    /// toward white (`lightenedBy`) or black (`darkenedBy`) — used to keep team
    /// colors legible as text against light/dark backgrounds.
    init(hex: String, lightenedBy lighten: Double = 0, darkenedBy darken: Double = 0) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        let red = Double((value & 0xFF0000) >> 16) / 255
        let green = Double((value & 0x00FF00) >> 8) / 255
        let blue = Double(value & 0x0000FF) / 255
        func adjust(_ channel: Double) -> Double {
            (channel + (1 - channel) * lighten) * (1 - darken)
        }
        self.init(.sRGB, red: adjust(red), green: adjust(green), blue: adjust(blue), opacity: 1)
    }
}
