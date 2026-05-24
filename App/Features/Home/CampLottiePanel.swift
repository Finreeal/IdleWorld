import SwiftUI

struct CampLottiePanel: View {
    let isWorking: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.06, blue: 0.10),
                            Color(red: 0.08, green: 0.09, blue: 0.14)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)

            ZStack {
                VStack(spacing: 0) {
                    Spacer(minLength: 0)

                    LinearGradient(
                        colors: [
                            Color(red: 0.09, green: 0.12, blue: 0.14).opacity(0.0),
                            Color(red: 0.09, green: 0.12, blue: 0.14).opacity(0.16)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 34)

                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.14, green: 0.28, blue: 0.18),
                                    Color(red: 0.10, green: 0.18, blue: 0.12)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 62)
                        .overlay(alignment: .top) {
                            Rectangle()
                                .fill(Color.white.opacity(0.05))
                                .frame(height: 1)
                        }
                }

                LottieView(
                    name: "sun",
                    loopMode: .loop,
                    contentMode: .scaleAspectFit,
                    animationSpeed: 0.7
                )
                .frame(width: 120, height: 120)
                .offset(x: 54, y: -42)
                .allowsHitTesting(false)

                LottieView(
                    name: "campfire",
                    loopMode: .loop,
                    contentMode: .scaleAspectFit,
                    animationSpeed: isWorking ? 1.0 : 0.72
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .allowsHitTesting(false)

                if !isWorking {
                    VStack {
                        Spacer()

                        HStack(spacing: 8) {
                            Image(systemName: "moon.zzz.fill")
                                .font(.caption.weight(.bold))
                            Text("Tábor odpočívá")
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundStyle(AppTheme.mutedText)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.black.opacity(0.28))
                        .clipShape(Capsule())
                        .padding(.bottom, 12)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        }
        .compositingGroup()
        .shadow(color: .black.opacity(0.22), radius: 18, x: 0, y: 12)
    }
}
