import SwiftUI

struct UnavailableView: View {
    let date: Date

    private var formattedDate: String {
        date.formatted(.dateTime.month(.wide).day().year())
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 6) {
                Text("Schedule Unavailable")
                    .font(.headline)
                Text("No data found for \(formattedDate).\nThe schedule may not be published yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}

#Preview {
    UnavailableView(date: Calendar.current.date(byAdding: .month, value: 5, to: Date())!)
}
