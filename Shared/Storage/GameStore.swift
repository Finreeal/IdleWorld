import Foundation
import WidgetKit

@MainActor
final class GameStore: ObservableObject {
    @Published private(set) var state: GameState = .initial
    @Published private(set) var sessions: [SessionLog] = []
    @Published private(set) var isCloudSyncEnabled = false
    @Published private(set) var isCloudAvailable = FileManager.default.ubiquityIdentityToken != nil

    private let defaults: UserDefaults
    private let cloudStore = NSUbiquitousKeyValueStore.default
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var cloudObserver: NSObjectProtocol?

    init(defaults: UserDefaults = UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard) {
        self.defaults = defaults
        cloudObserver = NotificationCenter.default.addObserver(
            forName: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: cloudStore,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                self?.mergeCloudIfNeeded()
            }
        }
    }

    deinit {
        if let cloudObserver {
            NotificationCenter.default.removeObserver(cloudObserver)
        }
    }

    var lastSessionSummary: String {
        guard let last = sessions.first else {
            return "Zatím žádný focus blok. Odlož telefon a vrať se později."
        }

        let minutes = Int(last.duration / 60)
        var rewards = ["+\(last.goldEarned) zlata", "+\(last.woodEarned) dřeva"]
        if last.stoneEarned > 0 {
            rewards.append("+\(last.stoneEarned) kamene")
        }
        return "Poslední návrat: \(rewards.joined(separator: ", ")) za \(minutes) min."
    }

    var totalFocusedHours: String {
        let hours = state.totalFocusedSeconds / 3600
        return String(format: "%.1f h", hours)
    }

    var recentSessions: [SessionLog] {
        Array(sessions.prefix(5))
    }

    var deepFocusSummary: String {
        "\(state.deepFocusSessionsCompleted) bloků • maximum \(state.bestFocusMinutes) min"
    }

    var activeTheme: WorldTheme {
        state.currentTheme
    }

    var productionSummary: String {
        var parts = [
            String(format: "%.1f zl/min", state.generationRate.goldPerMinute),
            String(format: "%.1f dř/min", state.generationRate.woodPerMinute)
        ]

        if state.generationRate.stonePerMinute > 0 {
            parts.append(String(format: "%.1f k/min", state.generationRate.stonePerMinute))
        }

        return parts.joined(separator: " • ")
    }

    var cloudStatusText: String {
        if !isCloudAvailable {
            return "iCloud není na tomto iPhonu aktivní. Přihlas se v Nastavení přes Apple ID, pokud chceš zálohovat pokrok."
        }

        return isCloudSyncEnabled
            ? "Pokrok se ukládá lokálně a zároveň do iCloudu."
            : "Pokrok se zatím ukládá jen lokálně v tomto zařízení."
    }

    var passiveGenerationStatusText: String {
        "Pasivní sběr se spustí, když iPhone zamkneš. Pouhé přepnutí do jiné aplikace se nepočítá."
    }

    func load() {
        refreshCloudAvailability()
        isCloudSyncEnabled = defaults.bool(forKey: AppConfig.cloudSyncPreferenceKey)

        if let storedState = decode(GameState.self, key: StorageKey.gameState.rawValue) {
            state = storedState
            reconcileLegacyState()
        }

        if let storedSessions = decode([SessionLog].self, key: StorageKey.sessions.rawValue) {
            sessions = storedSessions
        }

        if isCloudSyncEnabled {
            cloudStore.synchronize()
            mergeCloudIfNeeded()
        }
    }

    func refreshFromStorage() {
        load()
    }

    func enableCloudSync() {
        refreshCloudAvailability()
        guard isCloudAvailable else { return }
        isCloudSyncEnabled = true
        defaults.set(true, forKey: AppConfig.cloudSyncPreferenceKey)
        mergeCloudIfNeeded(forceUploadIfNeeded: true)
        save()
    }

    func disableCloudSync() {
        isCloudSyncEnabled = false
        defaults.set(false, forKey: AppConfig.cloudSyncPreferenceKey)
        saveLocalOnly()
    }

    func wipeAccountAndData() {
        clearCloudData()
        defaults.removeObject(forKey: StorageKey.gameState.rawValue)
        defaults.removeObject(forKey: StorageKey.sessions.rawValue)
        defaults.set(false, forKey: AppConfig.cloudSyncPreferenceKey)

        isCloudSyncEnabled = false
        state = .initial
        sessions = []
        saveLocalOnly()
    }

    func completeOnboarding() {
        let wasCloudEnabled = isCloudSyncEnabled
        state = .seeded
        if wasCloudEnabled {
            save()
        } else {
            saveLocalOnly()
        }
    }

    func markBackground(date: Date = .now) {
        state.lastBackgroundDate = date
        save()
    }

    func processReturn(at date: Date = .now) {
        guard let start = state.lastBackgroundDate, date > start else { return }

        let seconds = date.timeIntervalSince(start)
        state.lastBackgroundDate = nil
        applyReward(
            startDate: start,
            endDate: date,
            seconds: seconds,
            multiplier: 1,
            kind: .passive,
            title: "Tábor pracoval"
        )
    }

    func completeDeepFocusSession(_ session: FocusSessionPlan, at date: Date = .now, endedEarly: Bool) {
        let clampedEnd = min(date, session.endDate)
        let seconds = max(clampedEnd.timeIntervalSince(session.startDate), 0)
        guard seconds >= 60 else {
            save()
            return
        }

        let multiplier = endedEarly ? max(1.1, session.rewardMultiplier - 0.25) : session.rewardMultiplier
        state.deepFocusSessionsCompleted += endedEarly ? 0 : 1
        state.bestFocusMinutes = max(state.bestFocusMinutes, Int(seconds / 60))

        applyReward(
            startDate: session.startDate,
            endDate: clampedEnd,
            seconds: seconds,
            multiplier: multiplier,
            kind: .deepFocus,
            title: session.title
        )
    }

    func purchase(upgrade: Upgrade) {
        guard canAfford(upgrade: upgrade) else { return }
        guard meetsRequirement(for: upgrade) else { return }
        guard !isPurchased(upgrade: upgrade) else { return }

        state.gold -= upgrade.goldCost
        state.wood -= upgrade.woodCost
        state.ownedUpgradeIDs.append(upgrade.id)

        if let decoration = upgrade.decorationUnlocked,
           !state.unlockedDecorations.contains(decoration) {
            state.unlockedDecorations.append(decoration)
        }

        if let toolName = upgrade.equippedToolName {
            state.equippedTool = toolName
        }

        state.generationRate.goldPerMinute += upgrade.goldRateBonus
        state.generationRate.woodPerMinute += upgrade.woodRateBonus
        state.generationRate.stonePerMinute += upgrade.stoneRateBonus

        recalculateCampProgression()
        save()
    }

    func unlockTheme(_ theme: WorldTheme) {
        guard !state.unlockedThemes.contains(theme) else { return }
        guard state.gold >= theme.unlockCost else { return }
        state.gold -= theme.unlockCost
        state.unlockedThemes.append(theme)
        state.currentTheme = theme
        save()
    }

    func equipTheme(_ theme: WorldTheme) {
        guard state.unlockedThemes.contains(theme) else { return }
        state.currentTheme = theme
        save()
    }

    func updateHealthBonus(multiplier: Double, steps: Int) {
        state.healthBonusMultiplier = multiplier
        state.todaySteps = steps
        save()
    }

    func canAfford(upgrade: Upgrade) -> Bool {
        state.gold >= upgrade.goldCost && state.wood >= upgrade.woodCost
    }

    func meetsRequirement(for upgrade: Upgrade) -> Bool {
        state.campLevel >= upgrade.requiredCampLevel
    }

    func isPurchased(upgrade: Upgrade) -> Bool {
        state.ownedUpgradeIDs.contains(upgrade.id)
    }

    private func applyReward(
        startDate: Date,
        endDate: Date,
        seconds: TimeInterval,
        multiplier: Double,
        kind: SessionKind,
        title: String
    ) {
        let minuteFactor = seconds / 60
        let healthMultiplier = state.healthBonusMultiplier

        let totalGold = (minuteFactor * state.generationRate.goldPerMinute * multiplier * healthMultiplier) + state.productionCarryover.gold
        let totalWood = (minuteFactor * state.generationRate.woodPerMinute * multiplier * healthMultiplier) + state.productionCarryover.wood
        let totalStone = (minuteFactor * state.generationRate.stonePerMinute * multiplier * healthMultiplier) + state.productionCarryover.stone

        let earnedGold = Int(totalGold.rounded(.down))
        let earnedWood = Int(totalWood.rounded(.down))
        let earnedStone = Int(totalStone.rounded(.down))

        state.productionCarryover.gold = totalGold - Double(earnedGold)
        state.productionCarryover.wood = totalWood - Double(earnedWood)
        state.productionCarryover.stone = totalStone - Double(earnedStone)

        state.gold += earnedGold
        state.wood += earnedWood
        state.stone += earnedStone
        state.totalFocusedSeconds += seconds

        recalculateCampProgression()

        let log = SessionLog(
            startDate: startDate,
            endDate: endDate,
            duration: seconds,
            goldEarned: earnedGold,
            woodEarned: earnedWood,
            stoneEarned: earnedStone,
            kind: kind,
            title: title,
            bonusMultiplier: multiplier * healthMultiplier
        )

        sessions.insert(log, at: 0)
        sessions = Array(sessions.prefix(20))
        save()
    }

    private func recalculateCampProgression() {
        var nextLevel = 1

        if state.gold >= 300 || state.wood >= 220 {
            nextLevel = max(nextLevel, 2)
        }

        if state.gold >= 520 || state.wood >= 420 || state.deepFocusSessionsCompleted >= 3 {
            nextLevel = max(nextLevel, 3)
        }

        if state.gold >= 900 || state.wood >= 700 || state.stone >= 120 {
            nextLevel = max(nextLevel, 4)
        }

        state.campLevel = nextLevel

        if state.campLevel >= 3 {
            state.generationRate.stonePerMinute = max(state.generationRate.stonePerMinute, 0.25)
        }
    }

    private func reconcileLegacyState() {
        if state.equippedTool == "Wooden Pickaxe" {
            state.equippedTool = "Dřevěný krumpáč"
        }

        if state.unlockedDecorations.contains("Campfire") {
            state.unlockedDecorations.removeAll(where: { $0 == "Campfire" })
            if !state.unlockedDecorations.contains("Ohniště") {
                state.unlockedDecorations.append("Ohniště")
            }
        }

        recalculateCampProgression()
    }

    private func refreshCloudAvailability() {
        isCloudAvailable = FileManager.default.ubiquityIdentityToken != nil
    }

    private func mergeCloudIfNeeded(forceUploadIfNeeded: Bool = false) {
        guard isCloudSyncEnabled else { return }
        refreshCloudAvailability()
        guard isCloudAvailable else { return }

        let cloudState = decodeCloud(GameState.self, key: AppConfig.cloudStateKey)
        let cloudSessions = decodeCloud([SessionLog].self, key: AppConfig.cloudSessionsKey) ?? []

        if let cloudState {
            if cloudState.updatedAt > state.updatedAt {
                state = cloudState
                sessions = cloudSessions
                saveLocalOnly()
                return
            }
        }

        if forceUploadIfNeeded || cloudState == nil || state.updatedAt >= (cloudState?.updatedAt ?? .distantPast) {
            save()
        }
    }

    private func clearCloudData() {
        cloudStore.removeObject(forKey: AppConfig.cloudStateKey)
        cloudStore.removeObject(forKey: AppConfig.cloudSessionsKey)
        cloudStore.synchronize()
    }

    private func save() {
        state.updatedAt = .now
        encode(state, key: StorageKey.gameState.rawValue)
        encode(sessions, key: StorageKey.sessions.rawValue)

        if isCloudSyncEnabled && isCloudAvailable {
            encodeCloud(state, key: AppConfig.cloudStateKey)
            encodeCloud(sessions, key: AppConfig.cloudSessionsKey)
            cloudStore.synchronize()
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveLocalOnly() {
        state.updatedAt = .now
        encode(state, key: StorageKey.gameState.rawValue)
        encode(sessions, key: StorageKey.sessions.rawValue)
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func encode<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        defaults.set(data, forKey: key)
    }

    private func decode<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }

    private func encodeCloud<T: Encodable>(_ value: T, key: String) {
        guard let data = try? encoder.encode(value) else { return }
        cloudStore.set(data, forKey: key)
    }

    private func decodeCloud<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = cloudStore.data(forKey: key) else { return nil }
        return try? decoder.decode(type, from: data)
    }
}

private enum StorageKey: String {
    case gameState
    case sessions
}
