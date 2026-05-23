import Foundation

enum SessionKind: String, Codable {
    case passive
    case deepFocus
}

struct SessionLog: Codable, Equatable, Identifiable {
    let id: UUID
    let startDate: Date
    let endDate: Date
    let duration: TimeInterval
    let goldEarned: Int
    let woodEarned: Int
    let stoneEarned: Int
    let kind: SessionKind
    let title: String
    let bonusMultiplier: Double

    init(
        id: UUID = UUID(),
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        goldEarned: Int,
        woodEarned: Int,
        stoneEarned: Int = 0,
        kind: SessionKind,
        title: String,
        bonusMultiplier: Double = 1
    ) {
        self.id = id
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.goldEarned = goldEarned
        self.woodEarned = woodEarned
        self.stoneEarned = stoneEarned
        self.kind = kind
        self.title = title
        self.bonusMultiplier = bonusMultiplier
    }

    enum CodingKeys: String, CodingKey {
        case id
        case startDate
        case endDate
        case duration
        case goldEarned
        case woodEarned
        case stoneEarned
        case kind
        case title
        case bonusMultiplier
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        self.endDate = try container.decode(Date.self, forKey: .endDate)
        self.duration = try container.decode(TimeInterval.self, forKey: .duration)
        self.goldEarned = try container.decodeIfPresent(Int.self, forKey: .goldEarned) ?? 0
        self.woodEarned = try container.decodeIfPresent(Int.self, forKey: .woodEarned) ?? 0
        self.stoneEarned = try container.decodeIfPresent(Int.self, forKey: .stoneEarned) ?? 0
        self.kind = try container.decode(SessionKind.self, forKey: .kind)
        self.title = try container.decode(String.self, forKey: .title)
        self.bonusMultiplier = try container.decodeIfPresent(Double.self, forKey: .bonusMultiplier) ?? 1
    }
}
