import SwiftUI

// Cross-platform shims so the shared SwiftUI views compile on macOS (and visionOS),
// where several iOS-only modifiers/placements don't exist.

extension ToolbarItemPlacement {
    /// Leading slot — top-leading on iOS, the standard navigation slot elsewhere.
    static var gamedayLeading: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .navigation
        #endif
    }

    /// Trailing slot — top-trailing on iOS, the primary-action slot elsewhere.
    static var gamedayTrailing: ToolbarItemPlacement {
        #if os(iOS)
        .topBarTrailing
        #else
        .primaryAction
        #endif
    }

    /// Date controls — the bottom bar on iOS; macOS has none, so use the window toolbar.
    static var gamedayDateControls: ToolbarItemPlacement {
        #if os(iOS)
        .bottomBar
        #else
        .automatic
        #endif
    }
}

extension View {
    /// Inline navigation title on iOS; no-op where unavailable (macOS).
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Full-screen cover on iOS; a sheet on macOS (which has no full-screen cover).
    @ViewBuilder
    func adaptiveFullScreenCover<Content: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        #if os(iOS)
        fullScreenCover(isPresented: isPresented, content: content)
        #else
        sheet(isPresented: isPresented, content: content)
        #endif
    }

    /// Medium sheet detent on iOS; no-op on macOS (sheets there size to content).
    func mediumSheetDetent() -> some View {
        #if os(iOS)
        presentationDetents([.medium])
        #else
        self
        #endif
    }

    /// Wheel picker on iOS (compact, scrollable); a menu on macOS where wheel is unavailable.
    @ViewBuilder
    func longListPickerStyle() -> some View {
        #if os(iOS)
        pickerStyle(.wheel)
        #else
        pickerStyle(.menu)
        #endif
    }
}
