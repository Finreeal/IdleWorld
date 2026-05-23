import ActivityKit
import Foundation

struct DeepFocusActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var endDate: Date
        var title: String
        var goldPerMinute: Double
        var woodPerMinute: Double
        var campLevel: Int
        var decorationCount: Int
        var themeID: String
    }

    var sessionID: String
    var startDate: Date
}
