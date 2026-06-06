import SwiftUI

struct WelcomePage: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("GAMEDAY?")
                .font(.system(size: 44, weight: .black, design: .rounded))
            Text("Instantly know whether your team or favorite ballpark has a game today.")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(40)
    }
}
