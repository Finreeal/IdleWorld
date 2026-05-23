import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var gameStore: GameStore
    @State private var page = 0

    var body: some View {
        ZStack {
            AppTheme.background.ignoresSafeArea()

            TabView(selection: $page) {
                OnboardingPage(
                    title: "Váš hrdina čeká na skutečný svět",
                    subtitle: "Když bezcílně scrolluješ, tábor stojí. Když telefon odložíš, svět konečně pracuje.",
                    artwork: .sleepyHero
                )
                .tag(0)

                CloudBackupPage()
                    .tag(1)

                OnboardingPage(
                    title: "Pokrok vidíš přímo na ploše",
                    subtitle: "Widget ukazuje, kolik zlata a dřeva se ti mezitím podařilo získat.",
                    artwork: .widgetHarvest
                )
                .tag(2)

                VStack(spacing: 24) {
                    Spacer()

                    OnboardingHeroCircle {
                        Image(systemName: "campfire.fill")
                            .font(.system(size: 72, weight: .regular))
                            .foregroundStyle(AppTheme.gold, AppTheme.ember)
                    }

                    VStack(spacing: 12) {
                        Text("Oživit herní svět")
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)

                        Text("Připravíme ti startovní tábor a ukážeme, jak si přidat widget na plochu.")
                            .font(.callout)
                            .foregroundStyle(AppTheme.mutedText)
                            .multilineTextAlignment(.center)
                    }

                    WidgetPlaceholderCard()
                        .padding(.top, 4)

                    Button {
                        gameStore.completeOnboarding()
                        Haptics.playSuccess()
                    } label: {
                        Text("Spustit Idle World")
                            .font(.headline)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(AppTheme.gold)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .padding(.top, 8)

                    Text("Tip: podrž plochu iPhonu, klepni na + a vyber Idle World.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.mutedText)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
                .padding(24)
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
    }
}

private struct CloudBackupPage: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            OnboardingHeroCircle {
                ZStack {
                    Image(systemName: "icloud.fill")
                        .font(.system(size: 76, weight: .medium))
                        .foregroundStyle(AppTheme.mint, .white)

                    Image(systemName: gameStore.isCloudAvailable ? "checkmark.circle.fill" : "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(gameStore.isCloudAvailable ? AppTheme.gold : AppTheme.ember)
                        .offset(x: 46, y: 44)
                }
            }

            VStack(spacing: 14) {
                Text("Chceš si zachovat pokrok?")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text("Pokud chceš mít svět v bezpečí i po změně telefonu, můžeš zapnout ukládání do iCloudu přes své Apple ID.")
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            VStack(spacing: 12) {
                Button {
                    gameStore.enableCloudSync()
                    Haptics.playSuccess()
                } label: {
                    Text(gameStore.isCloudAvailable ? "Použít iCloud" : "iCloud není dostupný")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(gameStore.isCloudAvailable ? AppTheme.gold : AppTheme.mutedText)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .disabled(!gameStore.isCloudAvailable)

                Button {
                    gameStore.disableCloudSync()
                } label: {
                    Text("Pokračovat jen lokálně")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(AppTheme.mint)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }

            Text(gameStore.cloudStatusText)
                .font(.footnote)
                .foregroundStyle(AppTheme.mutedText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)

            Spacer()
        }
        .padding(24)
    }
}

private struct OnboardingPage: View {
    let title: String
    let subtitle: String
    let artwork: OnboardingArtwork

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            OnboardingHeroCircle {
                switch artwork {
                case .sleepyHero:
                    SleepyHeroArtwork()
                case .widgetHarvest:
                    WidgetHarvestArtwork()
                }
            }

            VStack(spacing: 14) {
                Text(title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.body)
                    .foregroundStyle(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            Spacer()
        }
        .padding(24)
    }
}

private enum OnboardingArtwork {
    case sleepyHero
    case widgetHarvest
}

private struct OnboardingHeroCircle<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.card, AppTheme.surface],
                        center: .center,
                        startRadius: 12,
                        endRadius: 120
                    )
                )
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.28), radius: 28, y: 18)

            content
        }
        .frame(width: 220, height: 220)
    }
}

private struct SleepyHeroArtwork: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.gold.opacity(0.14))
                .frame(width: 124, height: 124)
                .blur(radius: 10)

            VStack(spacing: 10) {
                ZStack {
                    Image(systemName: "moon.zzz.fill")
                        .font(.system(size: 58, weight: .regular))
                        .foregroundStyle(AppTheme.gold, AppTheme.mutedText)

                    Image(systemName: "person.crop.circle.badge.exclamationmark")
                        .font(.system(size: 46, weight: .medium))
                        .foregroundStyle(.white, AppTheme.ember)
                        .offset(x: -24, y: 22)
                }

                Text("Nečinný")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedText)
            }
        }
    }
}

private struct WidgetHarvestArtwork: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(AppTheme.surface)
                .frame(width: 138, height: 106)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Image(systemName: "rectangles.inset.filled")
                    .font(.system(size: 42, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))

                HStack(spacing: 18) {
                    VStack(spacing: 4) {
                        Image(systemName: "bitcoinsign.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.gold)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.gold.opacity(0.8))
                    }

                    VStack(spacing: 4) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(AppTheme.mint)
                        Image(systemName: "arrow.down")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(AppTheme.mint.opacity(0.8))
                    }
                }
            }

            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 26))
                .foregroundStyle(AppTheme.gold)
                .offset(x: 64, y: -16)

            Image(systemName: "leaf.arrow.triangle.circlepath")
                .font(.system(size: 24))
                .foregroundStyle(AppTheme.mint)
                .offset(x: -58, y: 24)
        }
    }
}

private struct WidgetPlaceholderCard: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(AppTheme.surface.opacity(0.92))

            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(
                    style: StrokeStyle(
                        lineWidth: 1.5,
                        lineCap: .round,
                        dash: [10, 8],
                        dashPhase: animate ? 36 : 0
                    )
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [AppTheme.gold.opacity(0.9), AppTheme.mint.opacity(0.65)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            VStack(spacing: 12) {
                Image(systemName: "plus.viewfinder")
                    .font(.system(size: 30, weight: .medium))
                    .foregroundStyle(AppTheme.gold)

                Text("Místo pro tvůj widget")
                    .font(.headline)
                    .foregroundStyle(.white)

                Text("Po prvním spuštění si sem přidáš Idle World a uvidíš tábor růst bez otevírání appky.")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.mutedText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
            .padding(22)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 148)
        .onAppear {
            withAnimation(.linear(duration: 1.8).repeatForever(autoreverses: false)) {
                animate = true
            }
        }
    }
}
