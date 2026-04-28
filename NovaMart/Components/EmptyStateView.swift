import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(AppTheme.Colors.primary.opacity(0.5))
                .symbolEffect(.pulse)

            VStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(.primary)

                Text(message)
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let action, let actionTitle {
                GlassButton(actionTitle, action: action)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ErrorRetryView: View {
    let error: AppError
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(AppTheme.Colors.error.opacity(0.6))

            VStack(spacing: AppSpacing.sm) {
                Text("Something went wrong")
                    .font(AppTheme.Typography.title3)
                    .foregroundStyle(.primary)

                Text(error.errorDescription ?? "An unexpected error occurred.")
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let retry = onRetry {
                GlassButton("Try Again", icon: "arrow.clockwise", action: retry)
                    .frame(maxWidth: 200)
            }
        }
        .padding(AppSpacing.xxxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
