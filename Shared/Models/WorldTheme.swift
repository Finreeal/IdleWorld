import SwiftUI

enum WorldTheme: String, CaseIterable, Identifiable, Codable {
    case medievalCamp
    case orbitalOutpost
    case arcaneGarden
    case neonLab

    var id: String { rawValue }

    var title: String {
        switch self {
        case .medievalCamp: return "Medieval Camp"
        case .orbitalOutpost: return "Orbital Outpost"
        case .arcaneGarden: return "Arcane Garden"
        case .neonLab: return "Neon Lab"
        }
    }

    var subtitle: String {
        switch self {
        case .medievalCamp: return "Starter theme"
        case .orbitalOutpost: return "Premium theme"
        case .arcaneGarden: return "Premium theme"
        case .neonLab: return "Premium theme"
        }
    }

    var unlockCost: Int {
        switch self {
        case .medievalCamp: return 0
        case .orbitalOutpost: return 260
        case .arcaneGarden: return 320
        case .neonLab: return 420
        }
    }

    var skyTop: Color {
        switch self {
        case .medievalCamp: return AppTheme.skyTop
        case .orbitalOutpost: return Color(red: 0.05, green: 0.10, blue: 0.24)
        case .arcaneGarden: return Color(red: 0.16, green: 0.09, blue: 0.22)
        case .neonLab: return Color(red: 0.03, green: 0.16, blue: 0.18)
        }
    }

    var skyBottom: Color {
        switch self {
        case .medievalCamp: return AppTheme.skyBottom
        case .orbitalOutpost: return Color(red: 0.19, green: 0.21, blue: 0.40)
        case .arcaneGarden: return Color(red: 0.31, green: 0.12, blue: 0.25)
        case .neonLab: return Color(red: 0.11, green: 0.29, blue: 0.22)
        }
    }

    var grass: Color {
        switch self {
        case .medievalCamp: return AppTheme.grass
        case .orbitalOutpost: return Color(red: 0.18, green: 0.20, blue: 0.25)
        case .arcaneGarden: return Color(red: 0.18, green: 0.29, blue: 0.18)
        case .neonLab: return Color(red: 0.10, green: 0.22, blue: 0.18)
        }
    }

    var accent: Color {
        switch self {
        case .medievalCamp: return AppTheme.gold
        case .orbitalOutpost: return Color(red: 0.58, green: 0.76, blue: 0.98)
        case .arcaneGarden: return Color(red: 0.81, green: 0.58, blue: 0.95)
        case .neonLab: return Color(red: 0.52, green: 0.97, blue: 0.82)
        }
    }
}
