import Foundation

enum UpgradeCategory: String, Codable, CaseIterable, Identifiable {
    case production = "Těžba a nástroje"
    case camp = "Rozšíření tábora"

    var id: String { rawValue }
}

struct Upgrade: Codable, Identifiable, Equatable {
    let id: String
    let category: UpgradeCategory
    let name: String
    let description: String
    let goldCost: Int
    let woodCost: Int
    let requiredCampLevel: Int
    let goldRateBonus: Double
    let woodRateBonus: Double
    let stoneRateBonus: Double
    let decorationUnlocked: String?
    let equippedToolName: String?
    let badge: String

    static let catalog: [Upgrade] = [
        Upgrade(
            id: "iron_pickaxe",
            category: .production,
            name: "Železný krumpáč",
            description: "Zvýší těžbu zlata a zvedne výkon každé minuty, kdy necháš telefon ležet.",
            goldCost: 140,
            woodCost: 60,
            requiredCampLevel: 1,
            goldRateBonus: 1.4,
            woodRateBonus: 0,
            stoneRateBonus: 0,
            decorationUnlocked: nil,
            equippedToolName: "Železný krumpáč",
            badge: "+zlato"
        ),
        Upgrade(
            id: "hardened_axe",
            category: .production,
            name: "Tvrzená sekera",
            description: "Přidá stabilní bonus ke dřevu a zefektivní sběr dřeva na pozadí.",
            goldCost: 110,
            woodCost: 95,
            requiredCampLevel: 1,
            goldRateBonus: 0,
            woodRateBonus: 1.3,
            stoneRateBonus: 0,
            decorationUnlocked: nil,
            equippedToolName: "Tvrzená sekera",
            badge: "+dřevo"
        ),
        Upgrade(
            id: "campfire_hearth",
            category: .camp,
            name: "Hřejivé ohniště",
            description: "Rozšíří tábor o plnohodnotný oheň a přidá malý bonus oběma hlavním surovinám.",
            goldCost: 90,
            woodCost: 50,
            requiredCampLevel: 1,
            goldRateBonus: 0.4,
            woodRateBonus: 0.2,
            stoneRateBonus: 0,
            decorationUnlocked: "Ohniště",
            equippedToolName: nil,
            badge: "dekorace"
        ),
        Upgrade(
            id: "second_tent",
            category: .camp,
            name: "Druhý stan",
            description: "Přidá dalšího hrdinu do tábora a zlepší celkovou produktivitu světa.",
            goldCost: 150,
            woodCost: 120,
            requiredCampLevel: 2,
            goldRateBonus: 0.7,
            woodRateBonus: 0.7,
            stoneRateBonus: 0,
            decorationUnlocked: "Druhý stan",
            equippedToolName: nil,
            badge: "+hrdina"
        ),
        Upgrade(
            id: "stone_well",
            category: .camp,
            name: "Studna",
            description: "Upevní tábor, zpříjemní život hrdinům a začne pomáhat i se sběrem kamene.",
            goldCost: 180,
            woodCost: 150,
            requiredCampLevel: 3,
            goldRateBonus: 0.2,
            woodRateBonus: 0.3,
            stoneRateBonus: 0.35,
            decorationUnlocked: "Studna",
            equippedToolName: nil,
            badge: "+kámen"
        )
    ]
}
