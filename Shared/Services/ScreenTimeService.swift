import Foundation

#if canImport(DeviceActivity)
import DeviceActivity
#endif

#if canImport(FamilyControls)
import FamilyControls
#endif

@MainActor
final class ScreenTimeService: ObservableObject {
    @Published private(set) var isFeatureAvailable = false
    @Published private(set) var isAuthorized = false
    @Published private(set) var authorizationStatusText = "Screen Time není zatím připravený."
    @Published private(set) var monitoringStatusText = "Režim sledování je vypnutý."
    @Published var isPickerPresented = false

#if canImport(FamilyControls)
    @Published var selection = FamilyActivitySelection()
#endif

    private let defaults = UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

#if canImport(DeviceActivity)
    private let activityName = DeviceActivityName(AppConfig.screenTimeActivityName)
#endif

    func configure() {
        refreshAvailability()
        loadSelection()
        refreshAuthorizationStatus()
    }

    func refreshAvailability() {
#if canImport(FamilyControls) && canImport(DeviceActivity)
        isFeatureAvailable = true
#else
        isFeatureAvailable = false
#endif
    }

    func refreshAuthorizationStatus() {
#if canImport(FamilyControls)
        let status = AuthorizationCenter.shared.authorizationStatus
        switch status {
        case .approved:
            isAuthorized = true
            authorizationStatusText = "Screen Time oprávnění je schválené."
        case .denied:
            isAuthorized = false
            authorizationStatusText = "Screen Time oprávnění bylo zamítnuté nebo zrušené."
        case .notDetermined:
            isAuthorized = false
            authorizationStatusText = "Screen Time oprávnění zatím nebylo udělené."
        default:
            isAuthorized = false
            authorizationStatusText = "Screen Time oprávnění je v neznámém stavu."
        }
#else
        isAuthorized = false
        authorizationStatusText = "Tento build nemá k dispozici Family Controls framework."
#endif
    }

    func requestAuthorization() {
#if canImport(FamilyControls)
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                refreshAuthorizationStatus()
                monitoringStatusText = "Oprávnění bylo udělené. Můžeš vybrat rušivé aplikace."
            } catch {
                refreshAuthorizationStatus()
                monitoringStatusText = "Žádost o Screen Time oprávnění se nepodařila dokončit. Zkontroluj capability Family Controls a Apple schválení entitlementu."
            }
        }
#else
        monitoringStatusText = "Family Controls framework není v tomto buildu dostupný."
#endif
    }

    func revokeAuthorization() {
#if canImport(FamilyControls)
        AuthorizationCenter.shared.revokeAuthorization { [weak self] _ in
            Task { @MainActor in
                self?.refreshAuthorizationStatus()
                self?.monitoringStatusText = "Screen Time oprávnění bylo odvolané."
            }
        }
#else
        monitoringStatusText = "Family Controls framework není v tomto buildu dostupný."
#endif
    }

    func persistSelection() {
#if canImport(FamilyControls)
        guard let data = try? encoder.encode(selection) else { return }
        defaults.set(data, forKey: AppConfig.screenTimeSelectionKey)
        monitoringStatusText = "Výběr rušivých aplikací je uložený."
#endif
    }

    func prepareMonitoringSchedule() {
#if canImport(DeviceActivity) && canImport(FamilyControls)
        guard isAuthorized else {
            monitoringStatusText = "Nejdřív je potřeba schválit Screen Time oprávnění."
            return
        }

        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true,
            warningTime: nil
        )

        do {
            let center = DeviceActivityCenter()
            center.stopMonitoring([activityName])
            try center.startMonitoring(activityName, during: schedule)
            monitoringStatusText = "Denní Device Activity rozvrh je připravený. Pro plné callbacky ještě bude potřeba DeviceActivityMonitor extension a schválený Family Controls entitlement."
        } catch {
            monitoringStatusText = "Device Activity monitoring se nepodařilo spustit. Bez Apple capability nebo správného entitlementu to iOS odmítne."
        }
#else
        monitoringStatusText = "Device Activity framework není v tomto buildu dostupný."
#endif
    }

    var selectionSummaryText: String {
#if canImport(FamilyControls)
        let appCount = selection.applicationTokens.count
        let categoryCount = selection.categoryTokens.count
        let webCount = selection.webDomainTokens.count
        return "\(appCount) aplikací • \(categoryCount) kategorií • \(webCount) webů"
#else
        return "Výběr aplikací není v tomto buildu dostupný."
#endif
    }

    private func loadSelection() {
#if canImport(FamilyControls)
        guard let data = defaults.data(forKey: AppConfig.screenTimeSelectionKey),
              let storedSelection = try? decoder.decode(FamilyActivitySelection.self, from: data) else {
            return
        }

        selection = storedSelection
#endif
    }
}
