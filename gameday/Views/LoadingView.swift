import SwiftUI

struct LoadingView: View {
    var body: some View {
        ProgressView()
            .scaleEffect(1.4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    LoadingView()
}
