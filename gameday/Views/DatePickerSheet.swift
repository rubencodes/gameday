import SwiftUI

struct DatePickerSheet: View {
    let viewModel: GamedayViewModel
    @Binding var isPresented: Bool
    /// Team/venue accent, passed in because a sheet gets a fresh environment and
    /// doesn't inherit the app's ambient .tint.
    let accent: Color

    // Edit a local draft so navigating months doesn't trigger reloads, and so
    // Cancel can discard without committing anything.
    @State private var draft: Date

    init(viewModel: GamedayViewModel, isPresented: Binding<Bool>, accent: Color) {
        self.viewModel = viewModel
        self._isPresented = isPresented
        self.accent = accent
        self._draft = State(initialValue: viewModel.selectedDate)
    }

    var body: some View {
        NavigationStack {
            DatePicker(
                "Select Date",
                selection: $draft,
                in: viewModel.dateRange,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal)
            .navigationTitle("Select Date")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
            // Picking a day dismisses immediately; the date commit (which triggers a
            // reload) is deferred a tick so it isn't batched with — and delaying — the dismiss.
            .onChange(of: draft) {
                let chosen = draft
                isPresented = false
                Task { @MainActor in
                    withAnimation { viewModel.selectedDate = chosen }
                }
            }
        }
        .tint(accent)   // color the selected day + month chevrons to match the app
        .mediumSheetDetent()
    }
}
