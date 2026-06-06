import SwiftUI

struct ErrorView: View {
    let onRetry: () async -> Void

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "baseball")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Couldn't load schedule")
                .foregroundStyle(.secondary)
            AsyncButton("Try again", action: onRetry)
                .buttonStyle(.bordered)
        }
    }
}

#Preview {
    ErrorView {
        try? await Task.sleep(for: .seconds(1))
    }
}
