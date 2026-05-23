import SwiftUI

struct CampArtwork: View {
    let level: Int
    let decorationCount: Int
    let isWorking: Bool
    var theme: WorldTheme = .medievalCamp

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [theme.skyTop, theme.skyBottom, theme.grass.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                SkyDetails(theme: theme)

                VStack(spacing: 0) {
                    Spacer()

                    ZStack(alignment: .bottom) {
                        Hills(theme: theme)

                        GroundPlate(theme: theme)
                            .frame(height: size.height * 0.42)

                        CampPath()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: size.width * 0.34, height: size.height * 0.24)
                            .offset(x: size.width * 0.04, y: size.height * 0.03)

                        HStack(alignment: .bottom, spacing: size.width * 0.06) {
                            TreeCluster(theme: theme)

                            Settlement(level: level, theme: theme)

                            if decorationCount > 0 {
                                Campfire(isWorking: isWorking, theme: theme)
                            }

                            if decorationCount > 1 {
                                SupplyCrates()
                            }

                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, size.width * 0.09)
                        .padding(.bottom, size.height * 0.075)

                        GrassTufts(theme: theme)
                            .padding(.horizontal, size.width * 0.06)
                            .padding(.bottom, size.height * 0.04)
                    }
                }

                if isWorking {
                    WorkingGlow(theme: theme)
                        .offset(x: -size.width * 0.01, y: size.height * 0.11)
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
    }
}

private struct SkyDetails: View {
    let theme: WorldTheme

    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [theme.accent.opacity(0.95), theme.accent.opacity(0.04)],
                            center: .center,
                            startRadius: 8,
                            endRadius: size.width * 0.18
                        )
                    )
                    .frame(width: size.width * 0.22, height: size.width * 0.22)
                    .blur(radius: 4)
                    .offset(x: size.width * 0.27, y: -size.height * 0.19)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [theme.accent, Color.white.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: size.width * 0.11, height: size.width * 0.11)
                    .offset(x: size.width * 0.27, y: -size.height * 0.19)

                ForEach(0..<11, id: \.self) { index in
                    Capsule()
                        .fill(Color.white.opacity(index.isMultiple(of: 2) ? 0.18 : 0.10))
                        .frame(width: CGFloat(18 + index * 4), height: 2)
                        .offset(
                            x: CGFloat((index * 23) % 120) - size.width * 0.2,
                            y: CGFloat((index * 17) % 48) - size.height * 0.32
                        )
                }
            }
        }
    }
}

private struct Hills: View {
    let theme: WorldTheme

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height

            ZStack(alignment: .bottom) {
                HillShape(curveHeight: 0.26, peakOffset: 0.18)
                    .fill(theme.grass.opacity(0.48))
                    .frame(width: width, height: height)

                HillShape(curveHeight: 0.20, peakOffset: -0.18)
                    .fill(theme.grass.opacity(0.68))
                    .frame(width: width, height: height * 0.88)
            }
        }
    }
}

private struct GroundPlate: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [theme.grass.opacity(0.95), AppTheme.grassShadow.opacity(0.92)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .frame(height: 18)
                .blur(radius: 6)
                .padding(.horizontal, 18)
                .offset(y: 6)
        }
        .shadow(color: .black.opacity(0.24), radius: 22, y: 10)
    }
}

private struct GrassTufts: View {
    let theme: WorldTheme

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<8, id: \.self) { index in
                VStack(spacing: 2) {
                    Capsule()
                        .fill(index.isMultiple(of: 2) ? theme.grass.opacity(0.9) : AppTheme.mint.opacity(0.65))
                        .frame(width: 3, height: 12)
                        .rotationEffect(.degrees(index.isMultiple(of: 2) ? -16 : 14))
                    Capsule()
                        .fill(theme.grass.opacity(0.72))
                        .frame(width: 2, height: 8)
                }
            }
            Spacer()
        }
    }
}

private struct TreeCluster: View {
    let theme: WorldTheme

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            ForEach(0..<2, id: \.self) { index in
                VStack(spacing: 0) {
                    ZStack(alignment: .bottom) {
                        Circle()
                            .fill(Color.black.opacity(0.16))
                            .frame(width: index == 0 ? 28 : 24, height: 8)
                            .offset(y: 14)

                        Triangle()
                            .fill(index == 0 ? theme.grass : AppTheme.mint.opacity(0.92))
                            .frame(width: index == 0 ? 34 : 28, height: index == 0 ? 34 : 28)
                            .shadow(color: .black.opacity(0.18), radius: 8, y: 5)

                        Triangle()
                            .fill(Color.white.opacity(0.10))
                            .frame(width: index == 0 ? 16 : 14, height: index == 0 ? 18 : 15)
                            .offset(x: -4, y: -5)
                    }

                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(AppTheme.wood)
                        .frame(width: 5, height: 12)
                }
            }
        }
    }
}

private struct Settlement: View {
    let level: Int
    let theme: WorldTheme

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.black.opacity(0.18))
                    .frame(width: level > 1 ? 54 : 44, height: 10)
                    .offset(y: 12)

                if level > 1 {
                    AdvancedTent(theme: theme)
                } else {
                    BaseTent(theme: theme)
                }
            }

            Rectangle()
                .fill(AppTheme.grassShadow.opacity(0.72))
                .frame(width: level > 1 ? 54 : 42, height: 4)
                .blur(radius: 1.6)
        }
    }
}

private struct BaseTent: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            Triangle()
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.91, green: 0.80, blue: 0.60), Color(red: 0.69, green: 0.55, blue: 0.34)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 42, height: 30)
                .shadow(color: .black.opacity(0.18), radius: 8, y: 5)

            Triangle()
                .fill(Color.white.opacity(0.16))
                .frame(width: 18, height: 14)
                .offset(x: -6, y: -7)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(AppTheme.wood.opacity(0.82))
                .frame(width: 4, height: 12)
                .offset(y: 4)
        }
    }
}

private struct AdvancedTent: View {
    let theme: WorldTheme

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.79, green: 0.66, blue: 0.47), Color(red: 0.58, green: 0.44, blue: 0.28)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 44, height: 26)
                .shadow(color: .black.opacity(0.16), radius: 8, y: 5)

            Triangle()
                .fill(
                    LinearGradient(
                        colors: [AppTheme.wood.opacity(0.95), Color(red: 0.32, green: 0.19, blue: 0.10)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 52, height: 24)
                .offset(y: -10)

            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(Color.black.opacity(0.12))
                .frame(width: 12, height: 10)
                .offset(y: 3)
        }
    }
}

private struct Campfire: View {
    let isWorking: Bool
    let theme: WorldTheme

    var body: some View {
        VStack(spacing: 2) {
            ZStack {
                Ellipse()
                    .fill(Color.black.opacity(0.16))
                    .frame(width: 28, height: 8)
                    .offset(y: 12)

                Circle()
                    .fill(theme.accent.opacity(isWorking ? 0.24 : 0.12))
                    .frame(width: 22, height: 22)
                    .blur(radius: isWorking ? 2 : 0)

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(AppTheme.wood)
                    .frame(width: 14, height: 3)
                    .rotationEffect(.degrees(24))

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(AppTheme.wood)
                    .frame(width: 14, height: 3)
                    .rotationEffect(.degrees(-24))

                Triangle()
                    .fill(isWorking ? theme.accent : AppTheme.ember)
                    .frame(width: 12, height: 14)

                Triangle()
                    .fill(Color(red: 1.0, green: 0.84, blue: 0.46))
                    .frame(width: 7, height: 8)
                    .offset(y: 1)
            }
        }
    }
}

private struct SupplyCrates: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 3) {
            crate(width: 13, height: 11, tint: AppTheme.wood.opacity(0.9))
            crate(width: 16, height: 13, tint: AppTheme.wood)
        }
    }

    private func crate(width: CGFloat, height: CGFloat, tint: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(tint)
                .frame(width: width, height: height)
            RoundedRectangle(cornerRadius: 1, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .frame(width: width - 4, height: 2)
                .offset(y: -2)
        }
        .shadow(color: .black.opacity(0.12), radius: 4, y: 3)
    }
}

private struct WorkingGlow: View {
    let theme: WorldTheme

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.accent.opacity(0.82 - Double(index) * 0.2))
                    .frame(width: 5, height: 5)
                    .scaleEffect(index == 1 ? 1.2 : 1)
            }
        }
    }
}

private struct HillShape: Shape {
    let curveHeight: CGFloat
    let peakOffset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - rect.height * 0.24))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY - rect.height * curveHeight),
            control: CGPoint(x: rect.width * 0.24, y: rect.maxY - rect.height * (curveHeight + 0.18 + peakOffset))
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.maxY - rect.height * 0.22),
            control: CGPoint(x: rect.width * 0.76, y: rect.maxY - rect.height * (curveHeight - 0.03 - peakOffset))
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

private struct CampPath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - 22, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX + 34, y: rect.maxY),
            control: CGPoint(x: rect.midX + 20, y: rect.midY)
        )
        path.addLine(to: CGPoint(x: rect.midX + 12, y: rect.maxY))
        path.addQuadCurve(
            to: CGPoint(x: rect.midX - 8, y: rect.minY + 8),
            control: CGPoint(x: rect.midX - 12, y: rect.midY)
        )
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
