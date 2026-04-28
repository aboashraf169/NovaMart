import SwiftUI

struct PriceView: View {
    let price: Decimal
    let compareAtPrice: Decimal?
    var size: PriceSize = .medium

    enum PriceSize {
        case small, medium, large

        var mainFont: Font {
            switch self {
            case .small: AppTheme.Typography.priceSmall
            case .medium: AppTheme.Typography.priceMedium
            case .large: AppTheme.Typography.priceLarge
            }
        }

        var strikeFont: Font {
            switch self {
            case .small: .caption
            case .medium: .callout
            case .large: .body
            }
        }
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: AppSpacing.xs) {
            Text(price.formatted)
                .font(size.mainFont)
                .foregroundStyle(compareAtPrice != nil ? AppTheme.Colors.accent : AppTheme.Colors.textPrimary)

            if let compare = compareAtPrice {
                Text(compare.formatted)
                    .font(size.strikeFont)
                    .strikethrough(true, color: .secondary)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(accessibilityValue)
    }

    private var accessibilityValue: String {
        if let compare = compareAtPrice {
            return "\(price.formatted), on sale from \(compare.formatted)"
        }
        return price.formatted
    }
}

// MARK: - Discount badge
struct DiscountBadge: View {
    let percent: Int

    var body: some View {
        Text("-\(percent)%")
            .font(.system(size: 11, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(AppTheme.Colors.accent, in: Capsule())
    }
}
