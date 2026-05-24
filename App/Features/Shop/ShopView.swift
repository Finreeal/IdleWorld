import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(spacing: 16) {
            ShopHeroCard()

            ForEach(UpgradeCategory.allCases) { category in
                ShopCategorySection(
                    category: category,
                    upgrades: Upgrade.catalog.filter { $0.category == category }
                )
            }
        }
    }
}

private struct ShopHeroCard: View {
    @EnvironmentObject private var gameStore: GameStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Obchod a ekonomika")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Nakupuj nástroje a rozšíření tábora. Každý upgrade se okamžitě promítne do produkce na pozadí i do odměn za soustředěné bloky.")
                .font(.callout)
                .foregroundStyle(AppTheme.mutedText)

            VStack(alignment: .leading, spacing: 8) {
                Label(gameStore.productionSummary, systemImage: "chart.line.uptrend.xyaxis")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                if gameStore.state.campLevel < 3 {
                    Text("Kámen se odemkne od úrovně tábora 3.")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.mutedText)
                } else {
                    Text("Kámen je aktivní: \(gameStore.state.stone) ks")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(AppTheme.mint)
                }
            }
            .padding(14)
            .background(AppTheme.card.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

private struct ShopCategorySection: View {
    let category: UpgradeCategory
    let upgrades: [Upgrade]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.rawValue)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)

            ForEach(upgrades) { upgrade in
                UpgradeCard(upgrade: upgrade)
            }
        }
    }
}

private struct UpgradeCard: View {
    @EnvironmentObject private var gameStore: GameStore
    let upgrade: Upgrade

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                iconBadge

                VStack(alignment: .leading, spacing: 6) {
                    Text(upgrade.name)
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text(upgrade.description)
                        .font(.callout)
                        .foregroundStyle(AppTheme.mutedText)

                    if upgrade.decorationUnlocked != nil || upgrade.id == "iron_pickaxe" || upgrade.id == "hardened_axe" {
                        Text("Po nákupu se změna hned objeví i v tábořišti.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.mint)
                    }
                }

                Spacer()

                Text(upgrade.badge)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.gold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(AppTheme.surface)
                    .clipShape(Capsule())
            }

            if upgrade.requiredCampLevel > 1 {
                Text("Vyžaduje tábor úrovně \(upgrade.requiredCampLevel)")
                    .font(.caption)
                    .foregroundStyle(gameStore.meetsRequirement(for: upgrade) ? AppTheme.mint : AppTheme.mutedText)
            }

            Text(effectLabel)
                .font(.caption)
                .foregroundStyle(AppTheme.gold.opacity(0.92))

            HStack {
                Text("Cena: \(upgrade.goldCost) zlata, \(upgrade.woodCost) dřeva")
                    .font(.footnote)
                    .foregroundStyle(AppTheme.mutedText)

                Spacer()

                Button {
                    gameStore.purchase(upgrade: upgrade)
                    Haptics.playImpact(style: .soft)
                } label: {
                    Text(buttonTitle)
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(gameStore.isPurchased(upgrade: upgrade) ? .white : .black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(buttonTint)
                        .clipShape(Capsule())
                }
                .disabled(gameStore.isPurchased(upgrade: upgrade) || !gameStore.canAfford(upgrade: upgrade) || !gameStore.meetsRequirement(for: upgrade))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private var buttonTitle: String {
        if gameStore.isPurchased(upgrade: upgrade) {
            return "Zakoupeno"
        }

        if !gameStore.meetsRequirement(for: upgrade) {
            return "Úroveň \(upgrade.requiredCampLevel)"
        }

        return "Koupit"
    }

    private var buttonTint: Color {
        if gameStore.isPurchased(upgrade: upgrade) {
            return AppTheme.surface
        }

        if !gameStore.canAfford(upgrade: upgrade) || !gameStore.meetsRequirement(for: upgrade) {
            return AppTheme.mutedText
        }

        return AppTheme.gold
    }

    private var effectLabel: String {
        var parts: [String] = []

        if upgrade.goldRateBonus > 0 {
            parts.append("+\(String(format: "%.1f", upgrade.goldRateBonus)) zlata/min")
        }

        if upgrade.woodRateBonus > 0 {
            parts.append("+\(String(format: "%.1f", upgrade.woodRateBonus)) dřeva/min")
        }

        if upgrade.stoneRateBonus > 0 {
            parts.append("+\(String(format: "%.2f", upgrade.stoneRateBonus)) kamene/min")
        }

        if let decoration = upgrade.decorationUnlocked {
            parts.append("Odemkne: \(decoration)")
        }

        if let toolName = upgrade.equippedToolName {
            parts.append("Nástroj: \(toolName)")
        }

        return parts.joined(separator: "  •  ")
    }

    @ViewBuilder
    private var iconBadge: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(AppTheme.surface)
                .frame(width: 46, height: 46)

            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(iconTint)
        }
    }

    private var symbol: String {
        switch upgrade.id {
        case "iron_pickaxe": return "hammer.fill"
        case "hardened_axe": return "tree.fill"
        case "campfire_hearth": return "flame.fill"
        case "second_tent": return "house.fill"
        case "stone_well": return "drop.circle.fill"
        default: return "shippingbox.fill"
        }
    }

    private var iconTint: Color {
        switch upgrade.category {
        case .production: return AppTheme.gold
        case .camp: return AppTheme.mint
        }
    }
}
