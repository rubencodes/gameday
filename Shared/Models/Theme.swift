import SwiftUI

/// A team's two-color palette, used to tint the app and widget. Venues theme
/// from their home team. Colors sourced from teamcolorcodes.com.
struct Theme {
    let primaryHex: String
    let secondaryHex: String

    var primary: Color { Color(hex: primaryHex) }
    var secondary: Color { Color(hex: secondaryHex) }

    /// Subtle team-tinted gradient for backgrounds — kept low-opacity so the
    /// YES/NO and other content stay legible across all 30 palettes.
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [primary.opacity(0.22), secondary.opacity(0.12)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Legible primary/secondary for text and icons on the themed surface, adjusted
    /// per color scheme so dark colors stay readable in dark mode and light colors
    /// (tans, silvers) stay readable in light mode.
    func accent(for scheme: ColorScheme) -> Color { Self.legible(primaryHex, for: scheme) }

    private static func legible(_ hex: String, for scheme: ColorScheme) -> Color {
        let (red, green, blue) = components(hex)
        switch scheme {
        case .dark:
            // Brighten dark team colors so they pop and stay readable on a dark
            // background, preserving hue & saturation (scale RGB up — don't wash toward
            // white, which is what made the previous version look muted). Already-bright
            // colors are left alone. (Deeply saturated blues remain lower-contrast — blue
            // is intrinsically low-luminance — so a few navy teams stay borderline.)
            let peak = max(red, green, blue)
            let floor = 0.95
            guard peak > 0, peak < floor else {
                return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
            }
            let scale = floor / peak
            return Color(.sRGB, red: min(red * scale, 1), green: min(green * scale, 1), blue: min(blue * scale, 1), opacity: 1)
        case .light:
            // Darken very light team colors (tans, silvers) so they read on white.
            let luminance = 0.2126 * red + 0.7152 * green + 0.0722 * blue
            if luminance > 0.6 {
                return Color(.sRGB, red: red * 0.55, green: green * 0.55, blue: blue * 0.55, opacity: 1)
            }
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        @unknown default:
            return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        }
    }

    private static func components(_ hex: String) -> (Double, Double, Double) {
        let cleaned = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&value)
        return (
            Double((value & 0xFF0000) >> 16) / 255,
            Double((value & 0x00FF00) >> 8) / 255,
            Double(value & 0x0000FF) / 255
        )
    }

    /// Fallback when a team has no palette entry (effectively unreachable — all 30 listed).
    static let neutral = Theme(primaryHex: "#8E8E93", secondaryHex: "#C7C7CC")

    /// Palette for an MLB team id (statsapi).
    static func team(_ teamId: String) -> Theme {
        guard let hex = palette[teamId] else { return neutral }
        return Theme(primaryHex: hex.primary, secondaryHex: hex.secondary)
    }

    // (primary, secondary) hex keyed by team id.
    private static let palette: [String: (primary: String, secondary: String)] = [
        "108": ("#003263", "#BA0021"), // LA Angels
        "109": ("#A71930", "#E3D4AD"), // Arizona
        "110": ("#DF4601", "#000000"), // Baltimore
        "111": ("#BD3039", "#0C2340"), // Boston
        "112": ("#0E3386", "#CC3433"), // Chi Cubs
        "113": ("#C6011F", "#000000"), // Cincinnati
        "114": ("#00385D", "#E50022"), // Cleveland
        "115": ("#333366", "#C4CED4"), // Colorado
        "116": ("#0C2340", "#FA4616"), // Detroit
        "117": ("#002D62", "#EB6E1F"), // Houston
        "118": ("#004687", "#BD9B60"), // Kansas City
        "119": ("#005A9C", "#EF3E42"), // LA Dodgers
        "120": ("#AB0003", "#14225A"), // Washington
        "121": ("#002D72", "#FF5910"), // NY Mets
        "133": ("#003831", "#EFB21E"), // Athletics
        "134": ("#27251F", "#FDB827"), // Pittsburgh
        "135": ("#2F241D", "#FFC425"), // San Diego
        "136": ("#0C2C56", "#005C5C"), // Seattle
        "137": ("#FD5A1E", "#27251F"), // San Francisco
        "138": ("#C41E3A", "#0C2340"), // St. Louis
        "139": ("#092C5C", "#8FBCE6"), // Tampa Bay
        "140": ("#003278", "#C0111F"), // Texas
        "141": ("#134A8E", "#1D2D5C"), // Toronto
        "142": ("#002B5C", "#D31145"), // Minnesota
        "143": ("#E81828", "#002D72"), // Philadelphia
        "144": ("#CE1141", "#13274F"), // Atlanta
        "145": ("#27251F", "#C4CED4"), // Chi White Sox
        "146": ("#00A3E0", "#EF3340"), // Miami
        "147": ("#003087", "#E4002C"), // NY Yankees
        "158": ("#12284B", "#FFC52F"), // Milwaukee
    ]
}
