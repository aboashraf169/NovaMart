import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonVariant
    let isLoading: Bool
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary, destructive, ghost
    }

    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonVariant = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button(action: {
            HapticService.shared.play(.impact(.medium))
            action()
        }) {
            HStack(spacing: AppSpacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .scaleEffect(0.8)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.system(size: 15, weight: .semibold))
                    }
                    Text(title)
                        .font(AppTheme.Typography.labelLarge)
                }
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.buttonHeight)
            .background(backgroundContent)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: style == .ghost ? 1.5 : 0)
            }
        }
        .buttonStyle(ScalePressEffect())
        .disabled(isLoading)
        .accessibilityLabel(title)
    }

    @ViewBuilder
    private var backgroundContent: some View {
        switch style {
        case .primary:
            LinearGradient(
                colors: [AppTheme.Colors.primary, Color(hex: "#9B59FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .secondary:
            Color(UIColor.secondarySystemBackground)
        case .destructive:
            LinearGradient(
                colors: [Color(hex: "#FF3B30"), Color(hex: "#FF6B6B")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ghost:
            Color.clear
        }
    }

    private var foregroundColor: Color {
        switch style {
        case .primary, .destructive: .white
        case .secondary: AppTheme.Colors.textPrimary
        case .ghost: AppTheme.Colors.primary
        }
    }

    private var borderColor: Color {
        switch style {
        case .ghost: AppTheme.Colors.primary.opacity(0.4)
        default: .clear
        }
    }
}

// MARK: - Floating Action Button
struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    var tint: Color = AppTheme.Colors.primary

    var body: some View {
        Button(action: {
            HapticService.shared.play(.impact(.medium))
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(tint)
                        .shadow(color: tint.opacity(0.4), radius: 12, y: 6)
                )
        }
        .buttonStyle(ScalePressEffect(scale: 0.92))
    }
}
