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

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.background, AppTheme.card],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Idle World")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(.white)

                        Text("Tábor úrovně \(entry.state.campLevel)")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.7))
                    }

                    Spacer()

                    Image(systemName: entry.state.lastBackgroundDate == nil ? "figure.wave" : "hammer.fill")
                        .font(.title3)
                        .foregroundStyle(entry.state.lastBackgroundDate == nil ? AppTheme.mutedText : AppTheme.gold)
                }

                HStack(alignment: .bottom, spacing: 16) {
                    CampArtwork(
                        level: entry.state.campLevel,
                        decorationCount: entry.state.unlockedDecorations.count,
                        isWorking: entry.state.lastBackgroundDate != nil,
                        theme: entry.state.currentTheme
                    )
                        .frame(width: 110, height: 72)

                    VStack(alignment: .leading, spacing: 10) {
                        WidgetStatRow(title: "Zlato", value: "\(entry.state.gold)", tint: AppTheme.gold)
                        WidgetStatRow(title: "Dřevo", value: "\(entry.state.wood)", tint: AppTheme.wood)
                        WidgetStatRow(
                            title: "Stav",
                            value: entry.state.lastBackgroundDate == nil ? "Odpočívá" : "Pracuje",
                            tint: entry.state.lastBackgroundDate == nil ? AppTheme.mutedText : AppTheme.mint
                        )
                    }
                }
            }
            .padding(16)
        }
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

private struct WidgetStatRow: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        HStack {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.white.opacity(0.7))

            Spacer()

            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
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
        .description("Maly mikrosvet, ktery roste, kdyz telefon nechas byt.")
        .supportedFamilies([.systemMedium])
    }
}

#Preview(as: .systemMedium) {
    IdleWorldWidget()
} timeline: {
    IdleWorldEntry(date: .now, state: .seeded)
}
