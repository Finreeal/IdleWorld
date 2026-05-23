import Foundation

enum FocusSessionPreset: String, CaseIterable, Identifiable, Codable {
    case sprint15
    case balance30
    case deep45
    case ritual60

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sprint15: return "Sprint"
        case .balance30: return "Balance"
        case .deep45: return "Deep"
        case .ritual60: return "Ritual"
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

    var title: String { "\(preset.title) Focus" }
    var duration: TimeInterval { endDate.timeIntervalSince(startDate) }
}
