import Foundation

final class WidgetStore {
    static let shared = WidgetStore()

    private let defaults = UserDefaults(suiteName: AppConfig.appGroupID) ?? .standard
    private let decoder = JSONDecoder()

    private init() {}

    func loadState() -> GameState {
        guard let data = defaults.data(forKey: "gameState"),
              let state = try? decoder.decode(GameState.self, from: data) else {
            return .seeded
        }

        return state
    }
}
