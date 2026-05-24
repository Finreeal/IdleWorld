import Foundation

#if canImport(DeviceActivity)
import DeviceActivity
#endif

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(ManagedSettings)
import ManagedSettings
#endif

#if canImport(DeviceActivity) && canImport(FamilyControls) && canImport(ManagedSettings)
final class ScreenTimeMonitorExtension: DeviceActivityMonitor {
    private let defaults = UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard
    private let decoder = JSONDecoder()
    private let store = ManagedSettingsStore(named: .init("IdleWorldShieldStore"))

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        applyStoredSelection()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        clearShields()
    }

    override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        applyStoredSelection()
    }

    override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
    }

    private func applyStoredSelection() {
        guard let data = defaults.data(forKey: AppConfig.screenTimeSelectionKey),
              let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) else {
            clearShields()
            return
        }

        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens

        if selection.categoryTokens.isEmpty {
            store.shield.applicationCategories = nil
        } else {
            store.shield.applicationCategories = .specific(selection.categoryTokens)
        }

        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    private func clearShields() {
        store.clearAllSettings()
    }
}
#else
final class ScreenTimeMonitorExtension: NSObject {}
#endif
