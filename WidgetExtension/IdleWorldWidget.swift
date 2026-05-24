import SwiftUI
import WidgetKit

struct IdleWorldEntry: TimelineEntry {
    let date: Date
    let state: GameState
}

struct IdleWorldProvider: TimelineProvider {
    func placeholder(in context: Context) -> IdleWorldEntry {
        IdleWorldEntry(date: .now, state: .seeded)
    }

    func getSnapshot(in context: Context, completion: @escaping (IdleWorldEntry) -> Void) {
        completion(IdleWorldEntry(date: .now, state: WidgetStore.shared.loadState()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<IdleWorldEntry>) -> Void) {
        let state = WidgetStore.shared.loadState()
        let entry = IdleWorldEntry(date: .now, state: state)
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: .now) ?? .now.addingTimeInterval(900)
        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct IdleWorldWidgetView: View {
    let entry: IdleWorldEntry

    private var isWorking: Bool {
        entry.state.lastBackgroundDate != nil
    }

    var body: some View {
        ZStack {
            Color.black

            CampArtwork(
                level: entry.state.campLevel,
                decorationCount: entry.state.unlockedDecorations.count,
                isWorking: isWorking,
                theme: entry.state.currentTheme,
                visualState: .from(state: entry.state)
            )
            .padding(.horizontal, -18)
            .padding(.vertical, -18)
            .overlay(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.28),
                        Color.clear,
                        Color.black.opacity(0.62)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            VStack(alignment: .leading, spacing: 0) {
                WidgetHeader(level: entry.state.campLevel, isWorking: isWorking)

                Spacer()

                HStack(spacing: 10) {
                    WidgetMetricCard(title: "Zlato", value: "\(entry.state.gold)", tint: AppTheme.gold) {
                        GoldPileIcon()
                    }

                    WidgetMetricCard(title: "Dřevo", value: "\(entry.state.wood)", tint: AppTheme.wood) {
                        WoodStackIcon()
                    }

                    WidgetMetricCard(
                        title: "Stav",
                        value: isWorking ? "Pracuje" : "Odpočívá",
                        tint: isWorking ? AppTheme.mint : AppTheme.mutedText
                    ) {
                        StatusOrbIcon(isWorking: isWorking)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 8)
        }
        .containerBackground(for: .widget) {
            Color.black
        }
    }
}

private struct WidgetHeader: View {
    let level: Int
    let isWorking: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Idle World")
                    .font(.system(size: 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)

                Text("Tábor úrovně \(level)")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
            }

            Spacer()

            HStack(spacing: 6) {
                Circle()
                    .fill(isWorking ? AppTheme.mint : Color.white.opacity(0.18))
                    .frame(width: 8, height: 8)
                    .shadow(color: (isWorking ? AppTheme.mint : .clear).opacity(0.8), radius: 5)

                Text(isWorking ? "Pracuje" : "Odpočívá")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(isWorking ? AppTheme.mint : Color.white.opacity(0.76))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
            )
        }
    }
}

private struct WidgetMetricCard<Icon: View>: View {
    let title: String
    let value: String
    let tint: Color
    @ViewBuilder let icon: () -> Icon

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                icon()
                    .frame(width: 18, height: 18)

                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.70))
                    .lineLimit(1)
            }

            Text(value)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(tint)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
    }
}

private struct GoldPileIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.gold.opacity(0.24), .clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 18
                    )
                )

            ZStack(alignment: .bottomLeading) {
                CoinDisc(offsetX: -5, offsetY: 3, scale: 0.78)
                CoinDisc(offsetX: 2, offsetY: 3, scale: 0.88)
                CoinDisc(offsetX: 8, offsetY: 3, scale: 0.78)
                CoinDisc(offsetX: -1, offsetY: -3, scale: 0.92)
                CoinDisc(offsetX: 6, offsetY: -4, scale: 1.0)
            }
        }
    }
}

private struct CoinDisc: View {
    let offsetX: CGFloat
    let offsetY: CGFloat
    let scale: CGFloat

    var body: some View {
        Circle()
            .fill(
                LinearGradient(
                    colors: [Color(red: 1.0, green: 0.95, blue: 0.68), AppTheme.gold, Color(red: 0.76, green: 0.54, blue: 0.16)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.28), lineWidth: 0.8)
                    Circle()
                        .stroke(Color.black.opacity(0.12), lineWidth: 0.6)
                        .padding(2.2)
                }
            )
            .shadow(color: AppTheme.gold.opacity(0.28), radius: 3, y: 2)
            .scaleEffect(scale)
            .offset(x: offsetX, y: offsetY)
    }
}

private struct WoodStackIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [AppTheme.wood.opacity(0.18), .clear],
                        center: .center,
                        startRadius: 2,
                        endRadius: 18
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                LogStick(angle: 0, offsetX: 0, offsetY: 0, width: 15)
                LogStick(angle: 0, offsetX: 4, offsetY: 0, width: 13)
                LogStick(angle: 0, offsetX: 2, offsetY: 0, width: 11)
            }
        }
    }
}

private struct LogStick: View {
    let angle: Double
    let offsetX: CGFloat
    let offsetY: CGFloat
    let width: CGFloat

    var body: some View {
        Capsule(style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(red: 0.82, green: 0.60, blue: 0.34), AppTheme.wood, Color(red: 0.34, green: 0.21, blue: 0.11)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: 5)
            .overlay(alignment: .leading) {
                Circle()
                    .fill(Color(red: 0.95, green: 0.82, blue: 0.61))
                    .frame(width: 4, height: 4)
                    .offset(x: 1)
            }
            .rotationEffect(.degrees(angle))
            .shadow(color: Color.black.opacity(0.25), radius: 2, y: 1)
            .offset(x: offsetX, y: offsetY)
    }
}

private struct StatusOrbIcon: View {
    let isWorking: Bool

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            (isWorking ? AppTheme.mint : Color.white.opacity(0.55)),
                            (isWorking ? AppTheme.mint.opacity(0.18) : Color.white.opacity(0.10)),
                            .clear
                        ],
                        center: .center,
                        startRadius: 1,
                        endRadius: 14
                    )
                )

            Circle()
                .fill(isWorking ? AppTheme.mint : Color.white.opacity(0.30))
                .frame(width: 10, height: 10)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.8)
                )
                .shadow(color: (isWorking ? AppTheme.mint : .clear).opacity(0.75), radius: 4)
        }
    }
}

struct IdleWorldWidget: Widget {
    let kind = "IdleWorldWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: IdleWorldProvider()) { entry in
            IdleWorldWidgetView(entry: entry)
        }
        .configurationDisplayName("Idle World")
        .description("Malý mikrosvět, který roste, když telefon necháš být.")
        .supportedFamilies([.systemMedium])
        .contentMarginsDisabled()
    }
}
