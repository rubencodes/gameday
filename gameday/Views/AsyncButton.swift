import SwiftUI

struct AsyncButton<Label: View>: View {
    private let action: () async -> Void
    private let label: Label

    @State private var isRunning = false

    init(action: @escaping () async -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button {
            guard !isRunning else { return }
            Task {
                isRunning = true
                await action()
                isRunning = false
            }
        } label: {
            label
                .opacity(isRunning ? 0 : 1)
                .overlay {
                    if isRunning { ProgressView().scaleEffect(0.7) }
                }
        }
        .disabled(isRunning)
    }
}

extension AsyncButton where Label == Text {
    init(_ title: String, action: @escaping () async -> Void) {
        self.init(action: action) { Text(title) }
    }
}

#Preview("Idle") {
    AsyncButton("Do something") {
        try? await Task.sleep(for: .seconds(2))
    }
    .buttonStyle(.bordered)
}
