import SwiftUI

@main
struct IdleWorldApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var gameStore = GameStore()
    @StateObject private var focusManager = FocusSessionManager()
    @StateObject private var healthBonusService = HealthBonusService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameStore)
                .environmentObject(focusManager)
                .environmentObject(healthBonusService)
                .task {
                    focusManager.configure(store: gameStore)
                    healthBonusService.configure(store: gameStore)
                    gameStore.load()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    handleScenePhaseChange(newPhase)
                }
        }
    }

    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            focusManager.appDidBecomeActive()
        case .background:
            focusManager.appDidEnterBackground()
        case .inactive:
            break
        @unknown default:
            break
        }
    }
}
