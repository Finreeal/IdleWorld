import Foundation

enum FocusSessionPreset: String, CaseIterable, Identifiable, Codable {
    case sprint15
    case balance30
    case deep45
    case ritual60

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sprint15: return "Rychlý sprint"
        case .balance30: return "Klidný blok"
        case .deep45: return "Hluboké ponoření"
        case .ritual60: return "Večerní rituál"
        }
    }

    var durationMinutes: Int {
        switch self {
        case .sprint15: return 15
        case .balance30: return 30
        case .deep45: return 45
        case .ritual60: return 60
        }
    }

    var rewardMultiplier: Double {
        switch self {
        case .sprint15: return 1.25
        case .balance30: return 1.45
        case .deep45: return 1.65
        case .ritual60: return 1.9
        }
    }

    var subtitle: String {
        "\(durationMinutes) min • \(String(format: "%.2fx", rewardMultiplier)) odměna"
    }

    var actionTitle: String {
        switch self {
        case .sprint15: return "Spustit rychlý sprint"
        case .balance30: return "Spustit klidný blok"
        case .deep45: return "Spustit hluboké ponoření"
        case .ritual60: return "Spustit večerní rituál"
        }
    }
}

struct FocusSessionPlan: Codable, Equatable, Identifiable {
    let id: UUID
    let preset: FocusSessionPreset
    let startDate: Date
    let endDate: Date
    let rewardMultiplier: Double
    let campLevelAtStart: Int
    let decorationCountAtStart: Int
    let themeAtStart: WorldTheme
    let goldRateAtStart: Double
    let woodRateAtStart: Double

    init(
        id: UUID = UUID(),
        preset: FocusSessionPreset,
        startDate: Date,
        endDate: Date,
        rewardMultiplier: Double,
        campLevelAtStart: Int,
        decorationCountAtStart: Int,
        themeAtStart: WorldTheme,
        goldRateAtStart: Double,
        woodRateAtStart: Double
    ) {
        self.id = id
        self.preset = preset
        self.startDate = startDate
        self.endDate = endDate
        self.rewardMultiplier = rewardMultiplier
        self.campLevelAtStart = campLevelAtStart
        self.decorationCountAtStart = decorationCountAtStart
        self.themeAtStart = themeAtStart
        self.goldRateAtStart = goldRateAtStart
        self.woodRateAtStart = woodRateAtStart
    }

    var title: String { preset.title }
    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }
}
