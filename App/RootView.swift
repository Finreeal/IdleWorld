import SwiftUI

struct RootView: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        Group {
            if gameStore.state.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
