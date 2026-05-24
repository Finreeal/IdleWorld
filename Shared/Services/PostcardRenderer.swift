import SwiftUI
import UIKit

@MainActor
enum PostcardRenderer {
    static func render(theme: WorldTheme, state: GameState) -> URL? {
        let renderer = ImageRenderer(content: PostcardView(theme: theme, state: state))
        renderer.scale = 3

        guard let image = renderer.uiImage,
              let data = image.pngData() else { return nil }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("idle-world-postcard-\(UUID().uuidString).png")
        try? data.write(to: url)
        return url
    }
}

private struct PostcardView: View {
    let theme: WorldTheme
    let state: GameState

    var body: some View {
        ZStack {
            LinearGradient(colors: [theme.skyTop, theme.skyBottom], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()

            RadialGradient(
                colors: [theme.accent.opacity(0.24), .clear],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Idle World")
                            .font(.system(size: 34, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        Text(theme.title)
                            .font(.headline)
                            .foregroundStyle(theme.accent)
                    }

                    Spacer()
                }

                CampArtwork(
                    level: state.campLevel,
                    decorationCount: state.unlockedDecorations.count,
                    isWorking: true,
                    theme: theme,
                    visualState: .from(state: state)
                )
                    .frame(height: 220)

                HStack(spacing: 14) {
                    StatCard(label: "Zlato", value: "\(state.gold)", tint: theme.accent, icon: "circle.hexagongrid.fill")
                    StatCard(label: "Dřevo", value: "\(state.wood)", tint: AppTheme.mint, icon: "tree.fill")
                    StatCard(label: "Tábor", value: "Úroveň \(state.campLevel)", tint: .white, icon: "trophy.fill")
                }

                Text("Vybudováno ve chvílích, kdy telefon dostal pauzu.")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(28)
        }
        .frame(width: 1080, height: 1350)
    }
}

private struct StatCard: View {
    let label: String
    let value: String
    let tint: Color
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(tint)

                Text(label)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.65))
            }

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(tint)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
