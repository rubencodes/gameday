import SwiftUI

struct OnboardingView: View {
    @Binding var filterKindRaw: String
    @Binding var selectedTeamId: String
    @Binding var selectedVenueId: Int
    let notifications: NotificationManager
    let onFinish: () -> Void

    @State private var page = 0
    private let pageCount = 4

    var body: some View {
        VStack(spacing: 0) {
            // One page at a time — advancing is driven solely by the CTA (no swipe),
            // so there's a single, unambiguous way forward.
            Group {
                switch page {
                case 0: WelcomePage()
                case 1: FeaturesPage()
                case 2:
                    SelectionPage(
                        filterKindRaw: $filterKindRaw,
                        selectedTeamId: $selectedTeamId,
                        selectedVenueId: $selectedVenueId
                    )
                default: NotificationsPage(notifications: notifications)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .transition(.opacity)
            .id(page)

            PageDots(count: pageCount, current: page)
                .padding(.bottom, 12)

            Button(page < pageCount - 1 ? "Continue" : "Get Started") {
                if page < pageCount - 1 {
                    withAnimation { page += 1 }
                } else {
                    onFinish()
                }
            }
            .buttonStyle(CTAButtonStyle())
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}
