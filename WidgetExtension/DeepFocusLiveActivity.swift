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
                    CampArtwork(
                        level: context.state.campLevel,
                        decorationCount: context.state.decorationCount,
                        isWorking: true,
                        theme: WorldTheme(rawValue: context.state.themeID) ?? .medievalCamp
                    )
                    .frame(width: 72, height: 52)
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(context.state.title)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)

                        Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                            .font(.title3.monospacedDigit().weight(.bold))
                            .foregroundStyle(AppTheme.gold)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label("\(Int(context.state.goldPerMinute)) zl/min", systemImage: "circle.hexagongrid.fill")
                        Spacer()
                        Label("\(Int(context.state.woodPerMinute)) dr/min", systemImage: "leaf.fill")
                    }
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)
                }
            } compactLeading: {
                Image(systemName: "flame.fill")
                    .foregroundStyle(AppTheme.gold)
            } compactTrailing: {
                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.caption2.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
            } minimal: {
                Image(systemName: "sparkles")
                    .foregroundStyle(AppTheme.gold)
            }
        }
    }
}

private struct DeepFocusLockScreenView: View {
    let context: ActivityViewContext<DeepFocusActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            CampArtwork(
                level: context.state.campLevel,
                decorationCount: context.state.decorationCount,
                isWorking: true,
                theme: WorldTheme(rawValue: context.state.themeID) ?? .medievalCamp
            )
            .frame(width: 120, height: 84)

            VStack(alignment: .leading, spacing: 8) {
                Text(context.state.title)
                    .font(.headline.weight(.heavy))
                    .foregroundStyle(.white)

                Text("Deep Focus bezi")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedText)

                Text(timerInterval: Date.now...context.state.endDate, countsDown: true)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                    .foregroundStyle(AppTheme.gold)

                HStack(spacing: 12) {
                    MetricPill(text: "\(Int(context.state.goldPerMinute)) zl/min", tint: AppTheme.gold)
                    MetricPill(text: "\(Int(context.state.woodPerMinute)) dr/min", tint: AppTheme.mint)
                }
            }
        }
        .padding(.vertical, 8)
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
