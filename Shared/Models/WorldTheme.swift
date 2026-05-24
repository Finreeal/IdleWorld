import SwiftUI

enum WorldTheme: String, CaseIterable, Identifiable, Codable {
    case medievalCamp
    case orbitalOutpost
    case arcaneGarden
    case neonLab

    var id: String { rawValue }

    var title: String {
        switch self {
        case .medievalCamp: return "Středověký tábor"
        case .orbitalOutpost: return "Orbitální základna"
        case .arcaneGarden: return "Magická zahrada"
        case .neonLab: return "Neonová laboratoř"
        }
    }

    var subtitle: String {
        switch self {
        case .medievalCamp: return "Klidná lesní výprava"
        case .orbitalOutpost: return "Tichá stanice nad Zemí"
        case .arcaneGarden: return "Zahrada se září a mlhou"
        case .neonLab: return "Noční laboratoř plná energie"
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

    var plateauTop: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.25, green: 0.36, blue: 0.23)
        case .orbitalOutpost: return Color(red: 0.20, green: 0.24, blue: 0.29)
        case .arcaneGarden: return Color(red: 0.24, green: 0.31, blue: 0.22)
        case .neonLab: return Color(red: 0.14, green: 0.23, blue: 0.19)
        }
    }

    var plateauSide: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.14, green: 0.18, blue: 0.13)
        case .orbitalOutpost: return Color(red: 0.10, green: 0.13, blue: 0.19)
        case .arcaneGarden: return Color(red: 0.15, green: 0.14, blue: 0.18)
        case .neonLab: return Color(red: 0.07, green: 0.11, blue: 0.11)
        }
    }

    var foliagePrimary: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.19, green: 0.30, blue: 0.19)
        case .orbitalOutpost: return Color(red: 0.38, green: 0.47, blue: 0.56)
        case .arcaneGarden: return Color(red: 0.26, green: 0.38, blue: 0.24)
        case .neonLab: return Color(red: 0.13, green: 0.30, blue: 0.24)
        }
    }

    var foliageSecondary: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.28, green: 0.41, blue: 0.24)
        case .orbitalOutpost: return Color(red: 0.51, green: 0.61, blue: 0.72)
        case .arcaneGarden: return Color(red: 0.45, green: 0.30, blue: 0.49)
        case .neonLab: return Color(red: 0.24, green: 0.58, blue: 0.46)
        }
    }

    var canvasPrimary: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.82, green: 0.73, blue: 0.58)
        case .orbitalOutpost: return Color(red: 0.76, green: 0.82, blue: 0.90)
        case .arcaneGarden: return Color(red: 0.78, green: 0.70, blue: 0.84)
        case .neonLab: return Color(red: 0.71, green: 0.83, blue: 0.79)
        }
    }

    var canvasSecondary: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.56, green: 0.47, blue: 0.34)
        case .orbitalOutpost: return Color(red: 0.42, green: 0.49, blue: 0.62)
        case .arcaneGarden: return Color(red: 0.46, green: 0.31, blue: 0.49)
        case .neonLab: return Color(red: 0.20, green: 0.39, blue: 0.34)
        }
    }

    var woodTint: Color {
        switch self {
        case .medievalCamp: return AppTheme.wood
        case .orbitalOutpost: return Color(red: 0.44, green: 0.48, blue: 0.55)
        case .arcaneGarden: return Color(red: 0.46, green: 0.34, blue: 0.41)
        case .neonLab: return Color(red: 0.24, green: 0.31, blue: 0.29)
        }
    }

    var stoneTint: Color {
        switch self {
        case .medievalCamp: return Color(red: 0.53, green: 0.50, blue: 0.46)
        case .orbitalOutpost: return Color(red: 0.50, green: 0.57, blue: 0.66)
        case .arcaneGarden: return Color(red: 0.55, green: 0.49, blue: 0.59)
        case .neonLab: return Color(red: 0.36, green: 0.45, blue: 0.42)
        }
    }
}
