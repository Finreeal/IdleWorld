import Foundation

struct GameState: Codable, Equatable {
    var gold: Int
    var wood: Int
    var stone: Int
    var campLevel: Int
    var equippedTool: String
    var currentTheme: WorldTheme
    var unlockedThemes: [WorldTheme]
    var lastBackgroundDate: Date?
    var totalFocusedSeconds: TimeInterval
    var deepFocusSessionsCompleted: Int
    var bestFocusMinutes: Int
    var healthBonusMultiplier: Double
    var todaySteps: Int
    var hasCompletedOnboarding: Bool
    var unlockedDecorations: [String]
    var ownedUpgradeIDs: [String]
    var generationRate: ResourceRate
    var productionCarryover: ResourceCarryover
    var updatedAt: Date

    static let initial = GameState(
        gold: 0,
        wood: 0,
        stone: 0,
        campLevel: 1,
        equippedTool: "Dřevěný krumpáč",
        currentTheme: .medievalCamp,
        unlockedThemes: [.medievalCamp],
        lastBackgroundDate: nil,
        totalFocusedSeconds: 0,
        deepFocusSessionsCompleted: 0,
        bestFocusMinutes: 0,
        healthBonusMultiplier: 1,
        todaySteps: 0,
        hasCompletedOnboarding: false,
        unlockedDecorations: [],
        ownedUpgradeIDs: [],
        generationRate: .base,
        productionCarryover: .zero,
        updatedAt: .now
    )

    static let seeded = GameState(
        gold: 120,
        wood: 80,
        stone: 0,
        campLevel: 1,
        equippedTool: "Dřevěný krumpáč",
        currentTheme: .medievalCamp,
        unlockedThemes: [.medievalCamp],
        lastBackgroundDate: nil,
        totalFocusedSeconds: 0,
        deepFocusSessionsCompleted: 0,
        bestFocusMinutes: 0,
        healthBonusMultiplier: 1,
        todaySteps: 0,
        hasCompletedOnboarding: true,
        unlockedDecorations: ["Ohniště"],
        ownedUpgradeIDs: [],
        generationRate: .base,
        productionCarryover: .zero,
        updatedAt: .now
    )

    enum CodingKeys: String, CodingKey {
        case gold
        case wood
        case stone
        case campLevel
        case equippedTool
        case currentTheme
        case unlockedThemes
        case lastBackgroundDate
        case totalFocusedSeconds
        case deepFocusSessionsCompleted
        case bestFocusMinutes
        case healthBonusMultiplier
        case todaySteps
        case hasCompletedOnboarding
        case unlockedDecorations
        case ownedUpgradeIDs
        case generationRate
        case productionCarryover
        case updatedAt
    }

    init(
        gold: Int,
        wood: Int,
        stone: Int,
        campLevel: Int,
        equippedTool: String,
        currentTheme: WorldTheme,
        unlockedThemes: [WorldTheme],
        lastBackgroundDate: Date?,
        totalFocusedSeconds: TimeInterval,
        deepFocusSessionsCompleted: Int,
        bestFocusMinutes: Int,
        healthBonusMultiplier: Double,
        todaySteps: Int,
        hasCompletedOnboarding: Bool,
        unlockedDecorations: [String],
        ownedUpgradeIDs: [String],
        generationRate: ResourceRate,
        productionCarryover: ResourceCarryover,
        updatedAt: Date
    ) {
        self.gold = gold
        self.wood = wood
        self.stone = stone
        self.campLevel = campLevel
        self.equippedTool = equippedTool
        self.currentTheme = currentTheme
        self.unlockedThemes = unlockedThemes
        self.lastBackgroundDate = lastBackgroundDate
        self.totalFocusedSeconds = totalFocusedSeconds
        self.deepFocusSessionsCompleted = deepFocusSessionsCompleted
        self.bestFocusMinutes = bestFocusMinutes
        self.healthBonusMultiplier = healthBonusMultiplier
        self.todaySteps = todaySteps
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.unlockedDecorations = unlockedDecorations
        self.ownedUpgradeIDs = ownedUpgradeIDs
        self.generationRate = generationRate
        self.productionCarryover = productionCarryover
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.gold = try container.decodeIfPresent(Int.self, forKey: .gold) ?? 0
        self.wood = try container.decodeIfPresent(Int.self, forKey: .wood) ?? 0
        self.stone = try container.decodeIfPresent(Int.self, forKey: .stone) ?? 0
        self.campLevel = try container.decodeIfPresent(Int.self, forKey: .campLevel) ?? 1
        self.equippedTool = try container.decodeIfPresent(String.self, forKey: .equippedTool) ?? "Dřevěný krumpáč"
        self.currentTheme = try container.decodeIfPresent(WorldTheme.self, forKey: .currentTheme) ?? .medievalCamp
        self.unlockedThemes = try container.decodeIfPresent([WorldTheme].self, forKey: .unlockedThemes) ?? [.medievalCamp]
        self.lastBackgroundDate = try container.decodeIfPresent(Date.self, forKey: .lastBackgroundDate)
        self.totalFocusedSeconds = try container.decodeIfPresent(TimeInterval.self, forKey: .totalFocusedSeconds) ?? 0
        self.deepFocusSessionsCompleted = try container.decodeIfPresent(Int.self, forKey: .deepFocusSessionsCompleted) ?? 0
        self.bestFocusMinutes = try container.decodeIfPresent(Int.self, forKey: .bestFocusMinutes) ?? 0
        self.healthBonusMultiplier = try container.decodeIfPresent(Double.self, forKey: .healthBonusMultiplier) ?? 1
        self.todaySteps = try container.decodeIfPresent(Int.self, forKey: .todaySteps) ?? 0
        self.hasCompletedOnboarding = try container.decodeIfPresent(Bool.self, forKey: .hasCompletedOnboarding) ?? false
        self.unlockedDecorations = try container.decodeIfPresent([String].self, forKey: .unlockedDecorations) ?? []
        self.ownedUpgradeIDs = try container.decodeIfPresent([String].self, forKey: .ownedUpgradeIDs) ?? []
        self.generationRate = try container.decodeIfPresent(ResourceRate.self, forKey: .generationRate) ?? .base
        self.productionCarryover = try container.decodeIfPresent(ResourceCarryover.self, forKey: .productionCarryover) ?? .zero
        self.updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? .distantPast
    }
}

struct ResourceRate: Codable, Equatable {
    var goldPerMinute: Double
    var woodPerMinute: Double
    var stonePerMinute: Double

    static let base = ResourceRate(goldPerMinute: 2, woodPerMinute: 1, stonePerMinute: 0)

    enum CodingKeys: String, CodingKey {
        case goldPerMinute
        case woodPerMinute
        case stonePerMinute
    }

    init(goldPerMinute: Double, woodPerMinute: Double, stonePerMinute: Double) {
        self.goldPerMinute = goldPerMinute
        self.woodPerMinute = woodPerMinute
        self.stonePerMinute = stonePerMinute
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.goldPerMinute = try container.decodeIfPresent(Double.self, forKey: .goldPerMinute) ?? 2
        self.woodPerMinute = try container.decodeIfPresent(Double.self, forKey: .woodPerMinute) ?? 1
        self.stonePerMinute = try container.decodeIfPresent(Double.self, forKey: .stonePerMinute) ?? 0
    }
}

struct ResourceCarryover: Codable, Equatable {
    var gold: Double
    var wood: Double
    var stone: Double

    static let zero = ResourceCarryover(gold: 0, wood: 0, stone: 0)
}
