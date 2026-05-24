import SwiftUI
import UIKit

@main
struct IdleWorldApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var gameStore = GameStore()
    @StateObject private var focusManager = FocusSessionManager()
    @StateObject private var healthBonusService = HealthBonusService()
    @StateObject private var screenTimeService = ScreenTimeService()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(gameStore)
                .environmentObject(focusManager)
                .environmentObject(healthBonusService)
                .environmentObject(screenTimeService)
                .task {
                    gameStore.load()
                    focusManager.configure(store: gameStore)
                    healthBonusService.configure(store: gameStore)
                    screenTimeService.configure()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.protectedDataWillBecomeUnavailableNotification)) { _ in
                    focusManager.deviceDidLock()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.protectedDataDidBecomeAvailableNotification)) { _ in
                    focusManager.deviceDidUnlock()
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
            focusManager.reconcileIfNeeded()
        @unknown default:
            break
        }
    }
}
