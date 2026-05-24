import SwiftUI

struct CampVisualState: Equatable {
    var showsCampfire: Bool
    var showsWoodPile: Bool
    var showsSecondTent: Bool
    var showsWell: Bool
    var showsStump: Bool
    var showsPickaxe: Bool
    var showsAxe: Bool
    var showsStoneCache: Bool
    var treeCount: Int

    static func derived(level: Int, decorationCount: Int) -> CampVisualState {
        CampVisualState(
            showsCampfire: decorationCount >= 1,
            showsWoodPile: decorationCount >= 1,
            showsSecondTent: level >= 2 || decorationCount >= 2,
            showsWell: level >= 3 || decorationCount >= 3,
            showsStump: true,
            showsPickaxe: false,
            showsAxe: false,
            showsStoneCache: level >= 3,
            treeCount: max(3, min(6, level + 2))
        )
    }

    static func from(state: GameState) -> CampVisualState {
        CampVisualState(
            showsCampfire: state.ownedUpgradeIDs.contains("campfire_hearth") || state.unlockedDecorations.contains("Ohniště"),
            showsWoodPile: state.ownedUpgradeIDs.contains("campfire_hearth") || state.unlockedDecorations.contains("Ohniště"),
            showsSecondTent: state.ownedUpgradeIDs.contains("second_tent") || state.unlockedDecorations.contains("Druhý stan"),
            showsWell: state.ownedUpgradeIDs.contains("stone_well") || state.unlockedDecorations.contains("Studna"),
            showsStump: true,
            showsPickaxe: state.ownedUpgradeIDs.contains("iron_pickaxe"),
            showsAxe: state.ownedUpgradeIDs.contains("hardened_axe"),
            showsStoneCache: state.campLevel >= 3 || state.ownedUpgradeIDs.contains("stone_well"),
            treeCount: max(3, min(6, state.campLevel + 2))
        )
    }
}

struct CampArtwork: View {
    let level: Int
    let decorationCount: Int
    let isWorking: Bool
    var theme: WorldTheme = .medievalCamp
    var visualState: CampVisualState? = nil

    private var resolvedVisualState: CampVisualState {
        visualState ?? .derived(level: level, decorationCount: decorationCount)
    }

    var body: some View {
        TimelineView(.periodic(from: .now, by: 0.65)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let glowPulse = 0.92 + (sin(t * 2.1) * 0.08)
            let firePulse = 0.94 + (sin(t * 7.2) * 0.06)
            let windShift = sin(t * 1.35) * 1.8

            GeometryReader { proxy in
                let size = proxy.size

                ZStack {
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    theme.skyTop,
                                    theme.skyBottom,
                                    Color.black.opacity(0.34)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    SkyLayer(theme: theme, glowPulse: glowPulse)

                    VStack(spacing: 0) {
                        Spacer(minLength: size.height * 0.18)

                        ZStack(alignment: .bottom) {
                            BackRidges(theme: theme)
                                .frame(width: size.width * 0.92, height: size.height * 0.30)
                                .offset(y: size.height * 0.02)

                            IsometricIsland(theme: theme)
                                .frame(width: size.width * 0.84, height: size.height * 0.50)
                                .offset(y: size.height * 0.04)

                            CampScene(
                                level: level,
                                isWorking: isWorking,
                                theme: theme,
                                visualState: resolvedVisualState,
                                firePulse: firePulse,
                                glowPulse: glowPulse,
                                windShift: windShift
                            )
                            .frame(width: size.width * 0.84, height: size.height * 0.50)
                                .offset(y: size.height * 0.01)
                        }

                        Spacer(minLength: 0)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        }
    }
}

private struct SkyLayer: View {
    let theme: WorldTheme
    let glowPulse: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.accent.opacity(0.30), .clear],
                            center: .center,
                            startRadius: 2,
                            endRadius: size.width * 0.20
                        )
                    )
                    .frame(width: size.width * 0.34, height: size.width * 0.34)
                    .scaleEffect(glowPulse)
                    .offset(x: size.width * 0.20, y: -size.height * 0.17)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.94), theme.accent.opacity(0.84)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.width * 0.11, height: size.width * 0.11)
                    .shadow(color: theme.accent.opacity(0.22), radius: 20, y: 8)
                    .scaleEffect(glowPulse)
                    .offset(x: size.width * 0.20, y: -size.height * 0.17)

                ForEach(0..<6, id: \.self) { index in
                    Capsule()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.10 : 0.06))
                        .frame(width: CGFloat(30 + index * 7), height: 2)
                        .offset(
                            x: CGFloat((index * 33) - 72),
                            y: CGFloat((index % 3) * 16) - size.height * 0.30
                        )
                }
            }
        }
    }
}

private struct BackRidges: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            RidgeShape(leftHeight: 0.55, centerHeight: 0.22, rightHeight: 0.48)
                .fill(theme.plateauTop.opacity(0.25))

            RidgeShape(leftHeight: 0.42, centerHeight: 0.12, rightHeight: 0.34)
                .fill(theme.plateauTop.opacity(0.42))
                .offset(y: 14)
        }
    }
}

private struct IsometricIsland: View {
    let theme: WorldTheme

    var body: some View {
        ZStack {
            IslandSide(side: .left, theme: theme)
            IslandSide(side: .right, theme: theme)

            Diamond()
                .fill(
                    LinearGradient(
                        colors: [
                            theme.plateauTop,
                            theme.plateauTop.opacity(0.98),
                            theme.plateauSide
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    Diamond()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.30), radius: 18, y: 12)

            GroundTexture(theme: theme)
                .padding(18)
                .mask(Diamond())

            Diamond()
                .stroke(Color.black.opacity(0.18), lineWidth: 10)
                .blur(radius: 12)
                .offset(y: 20)
                .padding(.horizontal, 26)
        }
    }
}

private struct IslandSide: View {
    enum Side {
        case left
        case right
    }

    let side: Side
    let theme: WorldTheme

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            Path { path in
                if side == .left {
                    path.move(to: CGPoint(x: width * 0.50, y: height * 0.50))
                    path.addLine(to: CGPoint(x: width * 0.24, y: height * 0.76))
                    path.addLine(to: CGPoint(x: width * 0.24, y: height * 0.92))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.66))
                } else {
                    path.move(to: CGPoint(x: width * 0.50, y: height * 0.50))
                    path.addLine(to: CGPoint(x: width * 0.76, y: height * 0.76))
                    path.addLine(to: CGPoint(x: width * 0.76, y: height * 0.92))
                    path.addLine(to: CGPoint(x: width * 0.50, y: height * 0.66))
                }
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [theme.plateauSide, theme.plateauSide.opacity(0.86)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

private struct GroundTexture: View {
    let theme: WorldTheme

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack {
                PathRibbon()
                    .fill(theme.stoneTint.opacity(0.24))
                    .frame(width: width * 0.26, height: height * 0.16)
                    .offset(x: width * 0.08, y: height * 0.12)

                ForEach(0..<14, id: \.self) { index in
                    Capsule()
                        .fill(index.isMultiple(of: 3) ? theme.foliageSecondary.opacity(0.24) : Color.white.opacity(0.06))
                        .frame(width: 5, height: CGFloat(8 + (index % 4) * 2))
                        .rotationEffect(.degrees(index.isMultiple(of: 2) ? -16 : 14))
                        .offset(
                            x: CGFloat((index * 29) % 100) / 100 * width - width / 2,
                            y: CGFloat((index * 17) % 52) / 52 * height - height / 2
                        )
                }

                ForEach(0..<7, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(theme.stoneTint.opacity(0.24))
                        .frame(width: CGFloat(7 + index % 2), height: CGFloat(4 + index % 2))
                        .offset(
                            x: CGFloat((index * 37) % 100) / 100 * width - width / 2,
                            y: CGFloat((index * 23) % 62) / 62 * height - height / 2
                        )
                }
            }
        }
    }
}

private struct CampScene: View {
    let level: Int
    let isWorking: Bool
    let theme: WorldTheme
    let visualState: CampVisualState
    let firePulse: Double
    let glowPulse: Double
    let windShift: Double

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                TreeGroup(theme: theme, count: visualState.treeCount, windShift: windShift)
                    .frame(width: size.width * 0.34, height: size.height * 0.34)
                    .offset(x: -size.width * 0.26, y: -size.height * 0.03)

                if visualState.showsWoodPile {
                    WoodStack(theme: theme)
                        .frame(width: size.width * 0.16, height: size.height * 0.10)
                        .offset(x: -size.width * 0.09, y: size.height * 0.10)
                }

                if visualState.showsPickaxe || visualState.showsAxe {
                    ToolRack(theme: theme, showsPickaxe: visualState.showsPickaxe, showsAxe: visualState.showsAxe)
                        .frame(width: size.width * 0.14, height: size.height * 0.12)
                        .offset(x: -size.width * 0.22, y: size.height * 0.11)
                }

                ExpeditionTent(style: level > 1 ? .large : .base, theme: theme)
                    .frame(width: size.width * 0.27, height: size.height * 0.19)
                    .offset(x: -size.width * 0.01, y: size.height * 0.00)

                if visualState.showsSecondTent {
                    ExpeditionTent(style: .small, theme: theme)
                        .frame(width: size.width * 0.18, height: size.height * 0.14)
                        .offset(x: size.width * 0.19, y: size.height * 0.01)
                }

                if visualState.showsCampfire {
                    FirePit(isWorking: isWorking, theme: theme, firePulse: firePulse)
                        .frame(width: size.width * 0.13, height: size.height * 0.12)
                        .offset(x: size.width * 0.11, y: size.height * 0.08)
                }

                if visualState.showsWell {
                    WellNode(theme: theme)
                        .frame(width: size.width * 0.12, height: size.height * 0.16)
                        .offset(x: size.width * 0.24, y: -size.height * 0.01)
                }

                if visualState.showsStump {
                    StumpNode(theme: theme)
                        .frame(width: size.width * 0.10, height: size.height * 0.10)
                        .offset(x: size.width * 0.28, y: size.height * 0.06)
                }

                if visualState.showsStoneCache {
                    StoneCache(theme: theme)
                        .frame(width: size.width * 0.14, height: size.height * 0.10)
                        .offset(x: size.width * 0.24, y: size.height * 0.12)
                }

                if isWorking {
                    WorkGlow(theme: theme, glowPulse: glowPulse)
                        .offset(x: size.width * 0.09, y: -size.height * 0.13)
                }
            }
        }
    }
}

private struct TreeGroup: View {
    let theme: WorldTheme
    let count: Int
    let windShift: Double

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                PineTree(
                    scale: 0.74 + CGFloat(index) * 0.06,
                    primary: index.isMultiple(of: 2) ? theme.foliagePrimary : theme.foliageSecondary,
                    secondary: theme.foliagePrimary.opacity(0.92),
                    trunk: theme.woodTint
                )
                .rotationEffect(.degrees((Double(index.isMultiple(of: 2) ? 1 : -1) * windShift) * 0.55))
                .offset(
                    x: CGFloat(index * 14) - 28,
                    y: CGFloat((index % 2) * 8)
                )
            }
        }
    }
}

private struct PineTree: View {
    let scale: CGFloat
    let primary: Color
    let secondary: Color
    let trunk: Color

    var body: some View {
        VStack(spacing: -5 * scale) {
            ForEach(0..<3, id: \.self) { index in
                Diamond()
                    .fill(index == 0 ? secondary : primary.opacity(1 - Double(index) * 0.08))
                    .frame(width: (28 - CGFloat(index) * 4) * scale, height: (21 - CGFloat(index) * 2) * scale)
                    .shadow(color: .black.opacity(0.14), radius: 5, y: 3)
            }

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(trunk)
                .frame(width: 5 * scale, height: 11 * scale)
        }
        .overlay(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 24 * scale, height: 7 * scale)
                .offset(y: 10 * scale)
        }
    }
}

private enum TentScale {
    case base
    case large
    case small
}

private struct ExpeditionTent: View {
    let style: TentScale
    let theme: WorldTheme

    private var width: CGFloat {
        switch style {
        case .base: return 72
        case .large: return 80
        case .small: return 50
        }
    }

    private var height: CGFloat {
        switch style {
        case .base: return 42
        case .large: return 48
        case .small: return 30
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.18))
                .frame(width: width * 0.92, height: 11)
                .offset(y: 15)

            ZStack {
                TentShape()
                    .fill(
                        LinearGradient(
                            colors: [theme.canvasPrimary, theme.canvasSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        TentShape()
                            .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.18), radius: 8, y: 6)

                TentFacet()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: width * 0.42, height: height * 0.60)
                    .offset(x: -width * 0.12, y: -height * 0.10)

                TentFrame()
                    .stroke(theme.woodTint.opacity(0.55), lineWidth: 1.6)

                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(Color.black.opacity(0.16))
                    .frame(width: width * 0.15, height: height * 0.28)
                    .offset(y: height * 0.11)
            }
            .frame(width: width, height: height)
        }
    }
}

private struct WoodStack: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 36, height: 9)
                .offset(y: 8)

            ForEach(0..<4, id: \.self) { index in
                LogBar(theme: theme, width: index.isMultiple(of: 2) ? 22 : 18)
                    .offset(x: CGFloat(index * 6), y: CGFloat(-(index % 2) * 4))
            }
        }
    }
}

private struct LogBar: View {
    let theme: WorldTheme
    let width: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            theme.canvasPrimary.opacity(0.80),
                            theme.woodTint,
                            theme.woodTint.opacity(0.78)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 8)

            Circle()
                .fill(theme.canvasPrimary.opacity(0.80))
                .frame(width: 6, height: 6)
                .offset(x: width / 2 - 5)
        }
    }
}

private struct FirePit: View {
    let isWorking: Bool
    let theme: WorldTheme
    let firePulse: Double

    var body: some View {
        ZStack {
            Ellipse()
                .fill(Color.black.opacity(0.18))
                .frame(width: 28, height: 9)
                .offset(y: 13)

            Circle()
                .fill(theme.accent.opacity(isWorking ? 0.18 : 0.08))
                .frame(width: 24, height: 24)
                .blur(radius: isWorking ? 4 : 1)
                .scaleEffect(isWorking ? firePulse : 1)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(theme.woodTint)
                .frame(width: 14, height: 3)
                .rotationEffect(.degrees(24))

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(theme.woodTint)
                .frame(width: 14, height: 3)
                .rotationEffect(.degrees(-24))

            Diamond()
                .fill(isWorking ? theme.accent : AppTheme.ember)
                .frame(width: 14, height: 18)
                .scaleEffect(x: isWorking ? (0.96 + (firePulse - 0.9)) : 1, y: isWorking ? firePulse : 1, anchor: .bottom)

            Diamond()
                .fill(Color(red: 1.0, green: 0.89, blue: 0.61))
                .frame(width: 7, height: 10)
                .scaleEffect(x: isWorking ? (0.98 + (firePulse - 0.9)) : 1, y: isWorking ? firePulse : 1, anchor: .bottom)
        }
    }
}

private struct WellNode: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.16))
                .frame(width: 26, height: 9)
                .offset(y: 12)

            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(theme.woodTint)
                        .frame(width: 4, height: 20)
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(theme.woodTint)
                        .frame(width: 4, height: 20)
                }

                Triangle()
                    .fill(theme.canvasSecondary)
                    .frame(width: 24, height: 12)
                    .offset(y: -6)

                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(theme.stoneTint)
                    .frame(width: 22, height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            }
        }
    }
}

private struct StumpNode: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 22, height: 7)
                .offset(y: 10)

            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(theme.woodTint)
                .frame(width: 14, height: 14)

            Circle()
                .stroke(theme.canvasPrimary.opacity(0.88), lineWidth: 1.2)
                .frame(width: 9, height: 9)
                .offset(y: -4)
        }
    }
}

private struct WorkGlow: View {
    let theme: WorldTheme
    let glowPulse: Double

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.accent.opacity(0.82 - Double(index) * 0.16))
                    .frame(width: index == 1 ? 6 : 5, height: index == 1 ? 6 : 5)
                    .scaleEffect(index == 1 ? glowPulse : (0.94 + (glowPulse - 0.9) * 0.6))
            }
        }
        .shadow(color: theme.accent.opacity(0.20), radius: 6)
    }
}

private struct ToolRack: View {
    let theme: WorldTheme
    let showsPickaxe: Bool
    let showsAxe: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.14))
                .frame(width: 32, height: 8)
                .offset(y: 8)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(theme.woodTint)
                .frame(width: 26, height: 3)

            if showsPickaxe {
                ToolHandle(theme: theme, angle: -24, headSymbol: .pickaxe)
                    .offset(x: -6, y: -6)
            }

            if showsAxe {
                ToolHandle(theme: theme, angle: 18, headSymbol: .axe)
                    .offset(x: 7, y: -6)
            }
        }
    }
}

private struct ToolHandle: View {
    enum HeadSymbol {
        case pickaxe
        case axe
    }

    let theme: WorldTheme
    let angle: Double
    let headSymbol: HeadSymbol

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(theme.woodTint)
                .frame(width: 3, height: 20)

            switch headSymbol {
            case .pickaxe:
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(theme.stoneTint)
                    .frame(width: 12, height: 3)
                    .offset(y: 2)
            case .axe:
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(theme.stoneTint)
                    .frame(width: 8, height: 4)
                    .offset(x: 3, y: 2)
            }
        }
        .rotationEffect(.degrees(angle), anchor: .bottom)
    }
}

private struct StoneCache: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            Ellipse()
                .fill(Color.black.opacity(0.12))
                .frame(width: 26, height: 8)
                .offset(y: 8)

            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(index == 1 ? theme.stoneTint.opacity(0.92) : theme.stoneTint.opacity(0.74))
                        .frame(width: 8, height: 8 + CGFloat(index % 2) * 3)
                }
            }
        }
    }
}

private struct RidgeShape: Shape {
    let leftHeight: CGFloat
    let centerHeight: CGFloat
    let rightHeight: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.height * leftHeight))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.height * centerHeight),
            control: CGPoint(x: rect.width * 0.28, y: rect.height * 0.06)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * rightHeight),
            control: CGPoint(x: rect.width * 0.76, y: rect.height * 0.14)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct PathRibbon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.28, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * 0.76),
            control: CGPoint(x: rect.width * 0.74, y: rect.height * 0.30)
        )
        path.addLine(to: CGPoint(x: rect.width * 0.84, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX, y: rect.height * 0.24),
            control: CGPoint(x: rect.width * 0.18, y: rect.height * 0.68)
        )
        path.closeSubpath()
        return path
    }
}

private struct TentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY * 0.58))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.44))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct TentFacet: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.18, y: rect.maxY * 0.62))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY + rect.height * 0.04))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.96))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.14, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct TentFrame: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.10, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY * 0.44))
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY * 0.96))
        return path
    }
}

private struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
