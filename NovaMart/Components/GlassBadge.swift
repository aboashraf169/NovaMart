import SwiftUI

struct GlassBadge: View {
    let text: String
    var icon: String? = nil
    var color: Color = AppTheme.Colors.primary
    var size: BadgeSize = .medium

    enum BadgeSize {
        case small, medium, large

        var font: Font {
            switch self {
            case .small: AppTheme.Typography.caption
            case .medium: AppTheme.Typography.captionBold
            case .large: AppTheme.Typography.labelSmall
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .small: 6
            case .medium: 10
            case .large: 14
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .small: 3
            case .medium: 5
            case .large: 7
            }
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: size == .small ? 9 : 11, weight: .semibold))
            }
            Text(text)
                .font(size.font)
                .fontWeight(.semibold)
        }
        .foregroundStyle(color)
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .background(.ultraThinMaterial, in: Capsule())
        .overlay(Capsule().strokeBorder(color.opacity(0.3), lineWidth: 0.5))
    }
}

// MARK: - Notification Badge
struct NotificationBadge: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text(count > 99 ? "99+" : "\(count)")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, count > 9 ? 5 : 0)
                .frame(minWidth: 18, minHeight: 18)
                .background(AppTheme.Colors.accent, in: Capsule())
                .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Corner ribbon
struct CornerRibbon: View {
    let text: String
    var color: Color = AppTheme.Colors.accent

    var body: some View {
        Text(text)
            .font(.system(size: 9, weight: .black))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
    }
}
