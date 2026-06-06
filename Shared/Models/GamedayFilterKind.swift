import Foundation

/// Whether a gameday lookup is scoped to a team or a venue. Shared by the app's
/// `@AppStorage` (via `rawValue`) and the widget's configuration intent. The widget
/// adds `AppEnum` conformance in its own target (see widget/AppIntentTypes.swift) so
/// these intent types are registered from exactly one module.
enum GamedayFilterKind: String, CaseIterable, Sendable {
    case team
    case venue
}
