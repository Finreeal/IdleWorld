import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif

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
                     : "Soustředění běží. Zamkni iPhone a nech svět chvíli růst.")
                    .font(.callout)
                    .foregroundStyle(AppTheme.mutedText)
            }

            DashboardHeroCard(
                level: gameStore.state.campLevel,
                decorationCount: gameStore.state.unlockedDecorations.count,
                totalFocusedHours: gameStore.totalFocusedHours,
                deepFocusSummary: gameStore.deepFocusSummary,
                isWorking: focusManager.isSessionRunning
            )

            HStack(spacing: 14) {
                ResourceCard(title: "Zlato", value: gameStore.state.gold, tint: AppTheme.gold)
                ResourceCard(title: "Dřevo", value: gameStore.state.wood, tint: AppTheme.wood)
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

    var body: some View {
        VStack(spacing: 14) {
            CampLottiePanel(isWorking: isWorking)
                .frame(height: 164)

            HStack(spacing: 10) {
                HeroMetric(title: "Úroveň", value: "\(level)", tint: AppTheme.gold)
                HeroMetric(title: "Dekorace", value: "\(decorationCount)", tint: AppTheme.mint)
                HeroMetric(title: "Čas", value: totalFocusedHours, tint: .white)
            }

            HStack {
                Text("Soustředěné bloky")
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
        case .focus: return "Soustředění"
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
            OverviewSnapshotCard()

            HintCard(
                title: "Jak svět pracuje",
                text: "Tábor sbírá suroviny, když iPhone opravdu zamkneš. Pro jistější a rychlejší výdělek můžeš kdykoli spustit soustředěný blok."
            )

            if !gameStore.state.unlockedDecorations.isEmpty {
                DecorationShelf(items: gameStore.state.unlockedDecorations)
            }

            SessionHistoryCard(sessions: gameStore.recentSessions)
        }
    }
}

private struct OverviewSnapshotCard: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Dnešní přehled")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                OverviewBadge(title: "Produkce", value: gameStore.productionSummary)
                OverviewBadge(title: "Téma", value: gameStore.activeTheme.title)
            }

            HStack(spacing: 12) {
                OverviewBadge(title: "Bonus za pohyb", value: String(format: "%.2fx", gameStore.state.healthBonusMultiplier))
                OverviewBadge(title: "Vylepšení", value: "\(gameStore.state.ownedUpgradeIDs.count)")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct OverviewBadge: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.mutedText)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
                        Text(selectedPreset.actionTitle)
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
            Text("Soustředění")
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text("Vybereš délku bloku, zamkneš iPhone a necháš tábor chvíli pracovat bez vyrušení. Odměna je vyšší než u pasivního sběru.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack(spacing: 10) {
                FocusBadge(text: "Live Activity")
                FocusBadge(text: "Zamčená obrazovka")
                FocusBadge(text: "Vyšší odměna")
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
            Text("Vyber režim")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(FocusSessionPreset.allCases) { preset in
                Button {
                    selectedPreset = preset
                    Haptics.playSelection()
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

                FocusBadge(text: "Běží")
            }

            CampLottiePanel(isWorking: true)
            .frame(height: 156)

            VStack(alignment: .leading, spacing: 8) {
                Text("Zbývající čas")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.mutedText)

                Text(timerInterval: Date.now...session.endDate, countsDown: true)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("Zisk: \(Int(session.goldRateAtStart * session.rewardMultiplier)) zlata/min • \(Int(session.woodRateAtStart * session.rewardMultiplier)) dřeva/min")
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
        }
    }
}

private struct ScreenTimeSetupCard: View {
    @EnvironmentObject private var screenTimeService: ScreenTimeService

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Screen Time experiment")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Tahle vrstva připravuje přesnější variantu Idle World přes Family Controls a Device Activity. Apple pro ni vyžaduje speciální capability a schválený entitlement.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            Text(screenTimeService.authorizationStatusText)
                .font(.footnote)
                .foregroundStyle(AppTheme.mutedText)

            Text("Výběr: \(screenTimeService.selectionSummaryText)")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(.white.opacity(0.88))

            HStack {
                Button("Požádat o oprávnění") {
                    screenTimeService.requestAuthorization()
                    Haptics.playSelection()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(Capsule())

                Button("Vybrat rušivé appky") {
                    screenTimeService.isPickerPresented = true
                    Haptics.playSelection()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.mint)
                .disabled(!screenTimeService.isFeatureAvailable)
            }

            HStack {
                Button("Připravit monitoring") {
                    screenTimeService.prepareMonitoringSchedule()
                    Haptics.playImpact(style: .light)
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.surface)
                .clipShape(Capsule())

                Button("Zrušit oprávnění") {
                    screenTimeService.revokeAuthorization()
                    Haptics.playWarning()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.red.opacity(0.92))
            }

            Text(screenTimeService.monitoringStatusText)
                .font(.caption)
                .foregroundStyle(AppTheme.mutedText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
#if canImport(FamilyControls)
        .familyActivityPicker(
            headerText: "Vyber aplikace, weby nebo kategorie, které chceš v budoucnu sledovat jako rušivé.",
            footerText: "Idle World si tenhle výběr uloží jako základ pro přesnější Screen Time režim.",
            isPresented: $screenTimeService.isPickerPresented,
            selection: $screenTimeService.selection
        )
        .onChange(of: screenTimeService.selection) { _, _ in
            screenTimeService.persistSelection()
        }
#endif
    }
}

private struct ThemeStudioCard: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Témata")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Každé téma mění náladu tábora i widgetu. Přepnout můžeš kdykoli bez ztráty pokroku.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

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
                            Haptics.playSelection()
                        }
                        .font(.caption.weight(.bold))
                        .foregroundStyle(gameStore.activeTheme == theme ? AppTheme.mint : AppTheme.gold)
                    } else {
                        Button("Odemknout za \(theme.unlockCost) zlata") {
                            gameStore.unlockTheme(theme)
                            Haptics.playImpact(style: .soft)
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
            Text("Bonus za pohyb")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Když povolíš přístup ke krokům, Idle World přidá malý bonus za reálný pohyb během dne.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            Text("Dnes: \(gameStore.state.todaySteps) kroků • bonus \(String(format: "%.2fx", gameStore.state.healthBonusMultiplier))")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            HStack {
                Button("Připojit Zdraví") {
                    healthBonusService.requestAccess()
                    Haptics.playSelection()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.black)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.gold)
                .clipShape(Capsule())
                .disabled(!healthBonusService.isAvailable)

                Button("Načíst kroky") {
                    healthBonusService.refreshTodaySteps()
                    Haptics.playSelection()
                }
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppTheme.mint)
                .disabled(!healthBonusService.isAvailable)
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
                    Haptics.playImpact(style: .light)
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

            Text("Datová vrstva je připravená pro komplikace a doprovodné watch pohledy. Další iterace může přidat samostatný Apple Watch target bez přestavby logiky aplikace.")
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
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            metricIcon

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

    @ViewBuilder
    private var metricIcon: some View {
        switch title {
        case "Úroveň":
            Image(systemName: "trophy.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
        case "Dekorace":
            Image(systemName: "tree.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
        default:
            Image(systemName: "hourglass")
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
        }
    }
}

private struct ResourceCard: View {
    let title: String
    let value: Int
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
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(tint.opacity(0.16), lineWidth: 1)
        )
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
    @EnvironmentObject private var gameStore: GameStore
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

            Text(gameStore.passiveGenerationStatusText)
                .font(.footnote)
                .foregroundStyle(AppTheme.mutedText.opacity(0.92))
                .fixedSize(horizontal: false, vertical: true)
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
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.gold.opacity(0.22), Color.clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 21
                    )
                )
                .frame(width: 42, height: 42)

            ZStack(alignment: .bottomLeading) {
                CoinDisc(size: 16).offset(x: -8, y: 8)
                CoinDisc(size: 18).offset(x: 2, y: 7)
                CoinDisc(size: 16).offset(x: 11, y: 8)
                CoinDisc(size: 18).offset(x: -3, y: -1)
                CoinDisc(size: 20).offset(x: 7, y: -2)
            }
        }
        .frame(width: 42, height: 42)
    }
}

private struct LogPileIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.wood.opacity(0.18), Color.clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 22
                    )
                )
                .frame(width: 42, height: 42)

            VStack(alignment: .leading, spacing: 3) {
                log(width: 24, offset: 0)
                log(width: 20, offset: 4)
                log(width: 16, offset: 2)
            }
        }
        .frame(width: 42, height: 42)
    }

    private func log(width: CGFloat, offset: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.78, green: 0.58, blue: 0.34),
                            AppTheme.wood,
                            Color(red: 0.33, green: 0.20, blue: 0.12)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: width, height: 8)
                .shadow(color: Color.black.opacity(0.16), radius: 2, y: 1)
            Circle()
                .fill(Color(red: 0.71, green: 0.52, blue: 0.32))
                .frame(width: 6, height: 6)
                .offset(x: width / 2 - 5)
        }
        .offset(x: offset)
    }
}

private struct CoinDisc: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.0, green: 0.95, blue: 0.68),
                            AppTheme.gold,
                            Color(red: 0.76, green: 0.54, blue: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Circle()
                .stroke(Color.white.opacity(0.28), lineWidth: 1)

            Circle()
                .stroke(Color.black.opacity(0.12), lineWidth: 1)
                .padding(3)
        }
        .frame(width: size, height: size)
        .shadow(color: AppTheme.gold.opacity(0.18), radius: 3, y: 2)
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
            Text("Poslední bloky")
                .font(.headline)
                .foregroundStyle(.white)

            if sessions.isEmpty {
                Text("Jakmile se vrátíš po chvíli mimo telefon nebo dokončíš soustředěný blok, objeví se tu historie zisků.")
                    .font(.callout)
                    .foregroundStyle(AppTheme.mutedText)
            } else {
                ForEach(sessions) { session in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Text("\(Int(session.duration / 60)) min • \(session.kind == .deepFocus ? "Soustředění" : "Pasivní sběr")")
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
