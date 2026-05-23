import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var focusManager: FocusSessionManager
    @EnvironmentObject private var healthBonusService: HealthBonusService
    @State private var selectedTab: HomeTab = .overview
    @State private var selectedPreset: FocusSessionPreset = .balance30
    @State private var postcardURL: URL?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        header
                        tabContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 108)
                }
            }
            .safeAreaInset(edge: .bottom) {
                BottomTabBar(selectedTab: $selectedTab)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .onAppear {
            gameStore.refreshFromStorage()
        }
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .overview:
            OverviewTab()
        case .focus:
            FocusTab(selectedPreset: $selectedPreset)
        case .studio:
            StudioTab(postcardURL: $postcardURL)
        case .shop:
            ShopView()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Idle World")
                    .font(.system(.largeTitle, design: .rounded, weight: .heavy))
                    .foregroundStyle(.white)

                Text(focusManager.activeSession == nil
                     ? "Tvůj mikrosvět roste, když dáš prostor skutečnému životu."
                     : "Deep Focus běží. Telefon může chvíli zmizet ze světa.")
                    .font(.callout)
                    .foregroundStyle(AppTheme.mutedText)
            }

            DashboardHeroCard(
                level: gameStore.state.campLevel,
                decorationCount: gameStore.state.unlockedDecorations.count,
                totalFocusedHours: gameStore.totalFocusedHours,
                deepFocusSummary: gameStore.deepFocusSummary,
                isWorking: focusManager.isSessionRunning,
                theme: gameStore.activeTheme
            )

            HStack(spacing: 14) {
                ResourceCard(title: "Zlato", value: gameStore.state.gold, symbol: "circle.hexagongrid.fill", tint: AppTheme.gold)
                ResourceCard(title: "Dřevo", value: gameStore.state.wood, symbol: "leaf.fill", tint: AppTheme.wood)
            }

            CampStatusCard(
                level: gameStore.state.campLevel,
                lastSession: gameStore.lastSessionSummary,
                totalFocusedHours: gameStore.totalFocusedHours,
                isWorking: focusManager.isSessionRunning
            )
        }
    }
}

private struct DashboardHeroCard: View {
    let level: Int
    let decorationCount: Int
    let totalFocusedHours: String
    let deepFocusSummary: String
    let isWorking: Bool
    let theme: WorldTheme

    var body: some View {
        VStack(spacing: 14) {
            CampArtwork(level: level, decorationCount: decorationCount, isWorking: isWorking, theme: theme)
                .frame(height: 164)

            HStack(spacing: 10) {
                HeroMetric(title: "Úroveň", value: "\(level)", symbol: "trophy.fill", tint: AppTheme.gold)
                HeroMetric(title: "Dekorace", value: "\(decorationCount)", symbol: "tree.fill", tint: AppTheme.mint)
                HeroMetric(title: "Focus", value: totalFocusedHours, symbol: "sparkles", tint: .white)
            }

            HStack {
                Text("Deep Focus")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)

                Spacer()

                Text(deepFocusSummary)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)
            }
            .padding(.horizontal, 2)
        }
        .padding(14)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
    }
}

private enum HomeTab: String, CaseIterable, Identifiable {
    case overview
    case focus
    case studio
    case shop

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Přehled"
        case .focus: return "Deep Focus"
        case .studio: return "Studio"
        case .shop: return "Obchod"
        }
    }

    var symbol: String {
        switch self {
        case .overview: return "sparkles"
        case .focus: return "timer"
        case .studio: return "paintpalette.fill"
        case .shop: return "bag.fill"
        }
    }
}

private struct OverviewTab: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(spacing: 16) {
            HintCard(
                title: "Jak Fáze 2 funguje",
                text: "Kromě pasivního progresu teď můžeš spustit i Deep Focus. Ten aktivuje Live Activity a dá vyšší odměnu za cílený blok soustředění."
            )

            HintCard(
                title: "Widget tip",
                text: "Po každém návratu se widget obnoví. Během Deep Focus se progres zobrazuje i na zamčené obrazovce a v Dynamic Island."
            )

            if !gameStore.state.unlockedDecorations.isEmpty {
                DecorationShelf(items: gameStore.state.unlockedDecorations)
            }

            SessionHistoryCard(sessions: gameStore.recentSessions)
        }
    }
}

private struct FocusTab: View {
    @Binding var selectedPreset: FocusSessionPreset
    @EnvironmentObject private var focusManager: FocusSessionManager

    var body: some View {
        VStack(spacing: 16) {
            FocusHeroCard()

            if let session = focusManager.activeSession {
                ActiveFocusCard(session: session)
            } else {
                PresetPickerCard(selectedPreset: $selectedPreset)

                Button {
                    focusManager.startDeepFocus(preset: selectedPreset)
                    Haptics.playSuccess()
                } label: {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("Spustit \(selectedPreset.title) Focus")
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(AppTheme.gold)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
            }
        }
    }
}

private struct FocusHeroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Deep Focus")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Vybereš délku bloku, zavřeš telefon a na zamčené obrazovce běží Live Activity s reálným časem i produkcí tábora.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack(spacing: 10) {
                FocusBadge(text: "Live Activity")
                FocusBadge(text: "Dynamic Island")
                FocusBadge(text: "Bonus odměna")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct PresetPickerCard: View {
    @Binding var selectedPreset: FocusSessionPreset

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Vyber blok")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(FocusSessionPreset.allCases) { preset in
                Button {
                    selectedPreset = preset
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(preset.title)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(preset.subtitle)
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedText)
                        }

                        Spacer()

                        Image(systemName: selectedPreset == preset ? "checkmark.circle.fill" : "circle")
                            .font(.title3)
                            .foregroundStyle(selectedPreset == preset ? AppTheme.gold : AppTheme.mutedText)
                    }
                    .padding(16)
                    .background(selectedPreset == preset ? AppTheme.elevated : AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ActiveFocusCard: View {
    let session: FocusSessionPlan
    @EnvironmentObject private var focusManager: FocusSessionManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(session.title)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Text(session.preset.subtitle)
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedText)
                }

                Spacer()

                FocusBadge(text: "Bezi")
            }

            CampArtwork(
                level: session.campLevelAtStart,
                decorationCount: session.decorationCountAtStart,
                isWorking: true,
                theme: session.themeAtStart
            )
            .frame(height: 156)

            VStack(alignment: .leading, spacing: 8) {
                Text("Zbývající čas")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.mutedText)

                Text(timerInterval: Date.now...session.endDate, countsDown: true)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Produkce: \(Int(session.goldRateAtStart * session.rewardMultiplier)) zlata/min • \(Int(session.woodRateAtStart * session.rewardMultiplier)) dřeva/min")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.gold)
            }

            Button(role: .destructive) {
                focusManager.endDeepFocusEarly()
            } label: {
                Text("Ukončit dříve")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.red.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct StudioTab: View {
    @Binding var postcardURL: URL?
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var healthBonusService: HealthBonusService

    var body: some View {
        VStack(spacing: 16) {
            ThemeStudioCard()
            HealthBonusCard()
            DataSettingsCard()
            PostcardCard(postcardURL: $postcardURL)
            WatchPreviewCard()
        }
    }
}

private struct ThemeStudioCard: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Témata")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(WorldTheme.allCases) { theme in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(LinearGradient(colors: [theme.skyTop, theme.skyBottom], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 54, height: 54)
                        .overlay(
                            Circle()
                                .fill(theme.accent)
                                .frame(width: 14, height: 14)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme.title)
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text(theme.subtitle)
                            .font(.caption)
                            .foregroundStyle(AppTheme.mutedText)
                    }

                    Spacer()

                    if gameStore.state.unlockedThemes.contains(theme) {
                        Button(gameStore.activeTheme == theme ? "Aktivní" : "Použít") {
                            gameStore.equipTheme(theme)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(gameStore.activeTheme == theme ? AppTheme.mint : AppTheme.gold)
                    } else {
                        Button("Odemknout za \(theme.unlockCost)") {
                            gameStore.unlockTheme(theme)
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                    }
                }
                .padding(14)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct HealthBonusCard: View {
    @EnvironmentObject private var gameStore: GameStore
    @EnvironmentObject private var healthBonusService: HealthBonusService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Health bonus")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Dnes: \(gameStore.state.todaySteps) kroků • bonus \(String(format: "%.2fx", gameStore.state.healthBonusMultiplier))")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                Button("Připojit Health") {
                    healthBonusService.requestAccess()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(Capsule())

                Button("Obnovit") {
                    healthBonusService.refreshTodaySteps()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.mint)
            }

            Text("Stav: \(healthBonusService.authorizationStatus)")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct DataSettingsCard: View {
    @EnvironmentObject private var gameStore: GameStore
    @State private var showDeleteDialog = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ukládání a účet")
                .font(.headline)
                .foregroundStyle(.white)

            Text(gameStore.cloudStatusText)
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                Button(gameStore.isCloudSyncEnabled ? "Ukládá se do iCloudu" : "Zapnout iCloud") {
                    if gameStore.isCloudSyncEnabled {
                        gameStore.disableCloudSync()
                    } else {
                        gameStore.enableCloudSync()
                    }
                    Haptics.playSuccess()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(gameStore.isCloudSyncEnabled ? AppTheme.mint : .black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(gameStore.isCloudSyncEnabled ? AppTheme.surface : AppTheme.gold)
                .clipShape(Capsule())
                .disabled(!gameStore.isCloudAvailable && !gameStore.isCloudSyncEnabled)

                Button("Smazat účet") {
                    showDeleteDialog = true
                    Haptics.playWarning()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.red.opacity(0.92))
            }

            Text("Smazání odstraní lokální data a případně i iCloud uložený pokrok. Potom se znovu zobrazí onboarding.")
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .confirmationDialog("Opravdu chceš smazat účet a uložený pokrok?", isPresented: $showDeleteDialog, titleVisibility: .visible) {
            Button("Pokračovat", role: .destructive) {
                showDeleteConfirmation = true
            }
            Button("Zrušit", role: .cancel) {}
        }
        .alert("Smazat účet?", isPresented: $showDeleteConfirmation) {
            Button("Smazat", role: .destructive) {
                gameStore.wipeAccountAndData()
            }
            Button("Zrušit", role: .cancel) {}
        } message: {
            Text("Tímto smažeš pokrok na tomto zařízení a vypneš iCloud synchronizaci. Pokud byla data zrcadlena do iCloudu, budou odstraněna i tam.")
        }
    }
}

private struct PostcardCard: View {
    @Binding var postcardURL: URL?
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Sdílet pohlednici")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Vygeneruj pohlednici se svým táborem a aktuálním tématem.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                Button("Vygenerovat") {
                    postcardURL = PostcardRenderer.render(theme: gameStore.activeTheme, state: gameStore.state)
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(Capsule())

                if let postcardURL {
                    ShareLink(item: postcardURL) {
                        Text("Sdílet")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(AppTheme.mint)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct WatchPreviewCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Apple Watch doplněk")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Datová vrstva je připravená pro komplikace a doprovodné watch pohledy. Další iterace může přidat samostatný watch target bez přestavby logiky appky.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                FocusBadge(text: "Připraveno pro komplikace")
                FocusBadge(text: "Živá data")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct FocusBadge: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(AppTheme.gold)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.surface)
            .clipShape(Capsule())
    }
}

private struct HeroMetric: View {
    let title: String
    let value: String
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: symbol)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)

            Text(value)
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(AppTheme.surface.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct ResourceCard: View {
    let title: String
    let value: Int
    let symbol: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            resourceIcon

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.mutedText)

            Text("\(value)")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private var resourceIcon: some View {
        if title == "Zlato" {
            CoinPileIcon()
        } else {
            LogPileIcon()
        }
    }
}

private struct CampStatusCard: View {
    let level: Int
    let lastSession: String
    let totalFocusedHours: String
    let isWorking: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Tábor úrovně \(level)")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.white)

                Spacer()

                Text(isWorking ? "Pracuje" : "Odpočívá")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isWorking ? AppTheme.mint : AppTheme.mutedText)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.surface)
                    .clipShape(Capsule())
            }

            Text(lastSession)
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)

            Text("Celkem soustředěného času: \(totalFocusedHours)")
                .font(.footnote)
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct BottomTabBar: View {
    @Binding var selectedTab: HomeTab

    var body: some View {
        HStack(spacing: 10) {
            ForEach(HomeTab.allCases) { tab in
                Button {
                    selectedTab = tab
                } label: {
                    VStack(spacing: 6) {
                        Image(systemName: tab.symbol)
                            .font(.system(size: 16, weight: .semibold))
                        Text(tab.title)
                            .font(.caption2.weight(.bold))
                    }
                    .foregroundStyle(selectedTab == tab ? .black : AppTheme.mutedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(selectedTab == tab ? AppTheme.gold : AppTheme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 10)
        .background(.ultraThinMaterial)
        .background(AppTheme.card.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .padding(.horizontal, 14)
        .padding(.bottom, 6)
    }
}

private struct CoinPileIcon: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Circle()
                .fill(AppTheme.gold.opacity(0.12))
                .frame(width: 42, height: 42)

            ForEach(0..<4, id: \.self) { index in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 1.0, green: 0.88, blue: 0.44), AppTheme.gold],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.22), lineWidth: 1)
                    )
                    .offset(x: CGFloat(index * 7), y: CGFloat(-(index % 2) * 4))
            }
        }
        .frame(width: 42, height: 42)
    }
}

private struct LogPileIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(AppTheme.wood.opacity(0.12))
                .frame(width: 42, height: 42)

            VStack(spacing: 4) {
                log(width: 24)
                log(width: 18)
            }
        }
        .frame(width: 42, height: 42)
    }

    private func log(width: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(AppTheme.wood)
                .frame(width: width, height: 8)
            Circle()
                .fill(Color(red: 0.71, green: 0.52, blue: 0.32))
                .frame(width: 6, height: 6)
                .offset(x: width / 2 - 5)
        }
    }
}

private struct HintCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            Text(text)
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct SessionHistoryCard: View {
    let sessions: [SessionLog]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Poslední sessiony")
                .font(.headline)
                .foregroundStyle(.white)

            if sessions.isEmpty {
                Text("Jakmile se vrátíš po chvíli mimo telefon nebo dokončíš Deep Focus, objeví se tu historie zisků.")
                    .font(.callout)
                    .foregroundStyle(AppTheme.mutedText)
            } else {
                ForEach(sessions) { session in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text("\(Int(session.duration / 60)) min • \(session.kind == .deepFocus ? "Deep Focus" : "Pasivní běh")")
                                .font(.caption)
                                .foregroundStyle(AppTheme.mutedText)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("+\(session.goldEarned) / +\(session.woodEarned)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.gold)

                            if session.bonusMultiplier > 1.01 {
                                Text("\(String(format: "%.2fx", session.bonusMultiplier)) bonus")
                                    .font(.caption2)
                                    .foregroundStyle(AppTheme.mint)
                            }
                        }
                    }
                    .padding(.vertical, 4)

                    if session.id != sessions.last?.id {
                        Divider()
                            .overlay(Color.white.opacity(0.06))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct DecorationShelf: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Odemčené dekorace")
                .font(.headline)
                .foregroundStyle(.white)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 12)], spacing: 12) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.gold)
                        .frame(maxWidth: .infinity, minHeight: 54)
                        .background(AppTheme.surface)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
    }
}
