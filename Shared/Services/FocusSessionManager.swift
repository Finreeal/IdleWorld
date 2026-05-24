import ActivityKit
import Foundation

@MainActor
final class FocusSessionManager: ObservableObject {
    @Published private(set) var isSessionRunning = false
    @Published private(set) var activeSession: FocusSessionPlan?

    private weak var store: GameStore?
    private let defaults = UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard

    func configure(store: GameStore) {
        self.store = store
        loadPersistedSession()
        reconcileIfNeeded()
    }

    func appDidEnterBackground(date: Date = .now) {
        reconcileIfNeeded(now: date)
        guard activeSession == nil else {
            isSessionRunning = true
            return
        }
    }

    func appDidBecomeActive(date: Date = .now) {
        reconcileIfNeeded(now: date)

        guard activeSession == nil else {
            isSessionRunning = true
            return
        }

        isSessionRunning = false
        store?.processReturn(at: date)
    }

    func deviceDidLock(date: Date = .now) {
        reconcileIfNeeded(now: date)
        guard activeSession == nil else {
            isSessionRunning = true
            return
        }

        isSessionRunning = true
        store?.markBackground(date: date)
    }

    func deviceDidUnlock(date: Date = .now) {
        reconcileIfNeeded(now: date)

        guard activeSession == nil else {
            isSessionRunning = true
            return
        }

        isSessionRunning = false
        store?.processReturn(at: date)
    }

    func startDeepFocus(preset: FocusSessionPreset, now: Date = .now) {
        guard let store, activeSession == nil else { return }

        let session = FocusSessionPlan(
            preset: preset,
            startDate: now,
            endDate: now.addingTimeInterval(TimeInterval(preset.durationMinutes * 60)),
            rewardMultiplier: preset.rewardMultiplier,
            campLevelAtStart: store.state.campLevel,
            decorationCountAtStart: store.state.unlockedDecorations.count,
            themeAtStart: store.state.currentTheme,
            goldRateAtStart: store.state.generationRate.goldPerMinute,
            woodRateAtStart: store.state.generationRate.woodPerMinute
        )

        activeSession = session
        isSessionRunning = true
        persist(session)

        Task {
            await startLiveActivity(for: session)
        }
    }

    func endDeepFocusEarly(now: Date = .now) {
        guard let session = activeSession else { return }
        finalize(session: session, at: now, endedEarly: true)
    }

    func reconcileIfNeeded(now: Date = .now) {
        guard let session = activeSession else { return }
        guard now >= session.endDate else { return }
        finalize(session: session, at: session.endDate, endedEarly: false)
    }

    private func finalize(session: FocusSessionPlan, at date: Date, endedEarly: Bool) {
        store?.completeDeepFocusSession(session, at: date, endedEarly: endedEarly)
        activeSession = nil
        clearPersistedSession()
        isSessionRunning = false

        Task {
            await endLiveActivity(for: session, finalDate: min(date, session.endDate))
        }
    }

    private func persist(_ session: FocusSessionPlan) {
        guard let data = try? JSONEncoder().encode(session) else { return }
        defaults.set(data, forKey: StorageKey.activeFocusSession.rawValue)
    }

    private func clearPersistedSession() {
        defaults.removeObject(forKey: StorageKey.activeFocusSession.rawValue)
    }

    private func loadPersistedSession() {
        guard let data = defaults.data(forKey: StorageKey.activeFocusSession.rawValue),
              let session = try? JSONDecoder().decode(FocusSessionPlan.self, from: data) else {
            return
        }

        activeSession = session
        isSessionRunning = true
    }

    private func startLiveActivity(for session: FocusSessionPlan) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        let attributes = DeepFocusActivityAttributes(
            sessionID: session.id.uuidString,
            startDate: session.startDate
        )

        let state = DeepFocusActivityAttributes.ContentState(
            endDate: session.endDate,
            title: session.title,
            goldPerMinute: session.goldRateAtStart * session.rewardMultiplier,
            woodPerMinute: session.woodRateAtStart * session.rewardMultiplier,
            campLevel: session.campLevelAtStart,
            decorationCount: session.decorationCountAtStart,
            themeID: session.themeAtStart.rawValue
        )

        do {
            _ = try Activity.request(attributes: attributes, content: .init(state: state, staleDate: nil))
        } catch {
            // Ignore Live Activity failures; focus mode still works without it.
        }
    }

    private func endLiveActivity(for session: FocusSessionPlan, finalDate: Date) async {
        let state = DeepFocusActivityAttributes.ContentState(
            endDate: finalDate,
            title: session.title,
            goldPerMinute: session.goldRateAtStart * session.rewardMultiplier,
            woodPerMinute: session.woodRateAtStart * session.rewardMultiplier,
            campLevel: session.campLevelAtStart,
            decorationCount: session.decorationCountAtStart,
            themeID: session.themeAtStart.rawValue
        )

        for activity in Activity<DeepFocusActivityAttributes>.activities where activity.attributes.sessionID == session.id.uuidString {
            await activity.end(.init(state: state, staleDate: nil), dismissalPolicy: .immediate)
        }
    }
}

private enum StorageKey: String {
    case activeFocusSession
}
