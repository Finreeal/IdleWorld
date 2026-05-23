import Foundation
import HealthKit

@MainActor
final class HealthBonusService: ObservableObject {
    @Published private(set) var authorizationStatus: String = "Not connected"
    @Published private(set) var todaySteps: Int = 0
    @Published private(set) var currentMultiplier: Double = 1

    private let healthStore = HKHealthStore()
    private weak var store: GameStore?

    func configure(store: GameStore) {
        self.store = store
    }

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAccess() {
        guard isAvailable,
              let steps = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            authorizationStatus = "Unavailable"
            return
        }

        healthStore.requestAuthorization(toShare: [], read: [steps]) { [weak self] success, _ in
            Task { @MainActor in
                self?.authorizationStatus = success ? "Connected" : "Denied"
                if success {
                    self?.refreshTodaySteps()
                }
            }
        }
    }

    func refreshTodaySteps() {
        guard let stepsType = HKQuantityType.quantityType(forIdentifier: .stepCount) else { return }
        let start = Calendar.current.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now)
        let query = HKStatisticsQuery(quantityType: stepsType, quantitySamplePredicate: predicate, options: .cumulativeSum) { [weak self] _, result, _ in
            let count = Int(result?.sumQuantity()?.doubleValue(for: HKUnit.count()) ?? 0)
            Task { @MainActor in
                self?.todaySteps = count
                self?.currentMultiplier = Self.multiplier(for: count)
                self?.store?.updateHealthBonus(multiplier: self?.currentMultiplier ?? 1, steps: count)
            }
        }

        healthStore.execute(query)
    }

    private static func multiplier(for steps: Int) -> Double {
        switch steps {
        case 12000...: return 1.35
        case 8000...: return 1.22
        case 5000...: return 1.12
        default: return 1
        }
    }
}
