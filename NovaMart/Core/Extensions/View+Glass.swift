import SwiftUI

extension View {
    func cardShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.card.color,
            radius: AppTheme.Shadow.card.radius,
            x: AppTheme.Shadow.card.x,
            y: AppTheme.Shadow.card.y
        )
    }

    func elevatedShadow() -> some View {
        self.shadow(
            color: AppTheme.Shadow.elevated.color,
            radius: AppTheme.Shadow.elevated.radius,
            x: AppTheme.Shadow.elevated.x,
            y: AppTheme.Shadow.elevated.y
        )
    }

    func adaptiveBackground() -> some View {
        self.background(AnimatedMeshBackground())
    }

    func sectionHeader() -> some View {
        self
            .font(AppTheme.Typography.title3)
            .foregroundStyle(AppTheme.Colors.textPrimary)
    }

    func conditionalGlass(_ condition: Bool, cornerRadius: CGFloat = AppTheme.Radius.card) -> some View {
        Group {
            if condition {
                self.glassCard(cornerRadius: cornerRadius)
            } else {
                self
            }
        }
    }
}
