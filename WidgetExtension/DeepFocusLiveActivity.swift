import ActivityKit
import SwiftUI
import WidgetKit

struct DeepFocusLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeepFocusActivityAttributes.self) { context in
            DeepFocusLockScreenView(context: context)
                .activityBackgroundTint(AppTheme.background)
                .activitySystemActionForegroundColor(AppTheme.gold)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    DeepFocusIslandScene(context: context)
                        .frame(width: 92, height: 58)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Soustředění")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)

                        Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            .font(.title3.monospacedDigit().weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 10) {
                        MetricPill(text: "\(Int(context.state.goldPerMinute)) zl/min", tint: AppTheme.gold)
                        MetricPill(text: "\(Int(context.state.woodPerMinute)) dř/min", tint: AppTheme.mint)
                        MetricPill(text: "Tábor \(context.state.campLevel)", tint: .white)
                        Spacer(minLength: 0)
                    }
                }
            } compactLeading: {
                ZStack {
                    Circle()
                        .fill(AppTheme.gold.opacity(0.22))
                    Image(systemName: "sparkles")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(AppTheme.gold)
                }
            } compactTrailing: {
                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.caption2.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
            } minimal: {
                Circle()
                    .fill(AppTheme.gold.opacity(0.26))
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                    )
            }
        }
    }
}

private struct DeepFocusLockScreenView: View {
    let context: ActivityViewContext<DeepFocusActivityAttributes>

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            CampArtwork(
                level: context.state.campLevel,
                decorationCount: context.state.decorationCount,
                isWorking: true,
                theme: WorldTheme(rawValue: context.state.themeID) ?? .medievalCamp
            )
            .overlay(
                LinearGradient(
                    colors: [Color.black.opacity(0.22), Color.black.opacity(0.68)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.title)
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(.white)

                        Text("Soustředění běží")
                            .font(.caption)
                            .foregroundStyle(Color.white.opacity(0.72))
                    }

                    Spacer()

                    Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(AppTheme.gold)
                }

                HStack(spacing: 10) {
                    MetricPill(text: "\(Int(context.state.goldPerMinute)) zl/min", tint: AppTheme.gold)
                    MetricPill(text: "\(Int(context.state.woodPerMinute)) dř/min", tint: AppTheme.mint)
                    MetricPill(text: "Tábor \(context.state.campLevel)", tint: .white)
                }
            }
            .padding(16)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

private struct DeepFocusIslandScene: View {
    let context: ActivityViewContext<DeepFocusActivityAttributes>

    var body: some View {
        CampArtwork(
            level: context.state.campLevel,
            decorationCount: context.state.decorationCount,
            isWorking: true,
            theme: WorldTheme(rawValue: context.state.themeID) ?? .medievalCamp
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct MetricPill: View {
    let text: String
    let tint: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(AppTheme.surface)
            .clipShape(Capsule())
    }
}
