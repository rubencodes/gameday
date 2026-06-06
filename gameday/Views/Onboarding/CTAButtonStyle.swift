import SwiftUI

/// Full-width prominent CTA. Applying the fill/padding inside the style (to the
/// label) and setting `contentShape` makes the entire pill tappable, not just the text.
struct CTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor, in: .rect(cornerRadius: 14))
            .foregroundStyle(.white)
            .contentShape(.rect(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
