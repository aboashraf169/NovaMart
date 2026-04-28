import SwiftUI

struct ForgotPasswordView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var sent = false

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: AppSpacing.xl) {
                    if sent {
                        // Success state
                        VStack(spacing: AppSpacing.lg) {
                            Image(systemName: "envelope.badge.fill")
                                .font(.system(size: 64, weight: .thin))
                                .foregroundStyle(AppTheme.Colors.secondary)
                                .symbolEffect(.pulse)

                            Text("Check your email")
                                .font(AppTheme.Typography.title2)

                            Text("We've sent password reset instructions to **\(viewModel.email)**")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            GlassButton("Done", action: { dismiss() })
                        }
                        .padding(AppSpacing.screenPadding)
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Forgot Password?")
                                .font(AppTheme.Typography.title2)

                            Text("Enter your email address and we'll send you a reset link.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(.secondary)

                            AuthField(
                                title: "Email",
                                text: $viewModel.email,
                                icon: "envelope.fill",
                                type: .emailAddress
                            )

                            GlassButton("Send Reset Link", icon: "paperplane.fill", isLoading: viewModel.isLoading) {
                                Task {
                                    let success = await viewModel.forgotPassword()
                                    if success {
                                        withAnimation(.smooth) { sent = true }
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.screenPadding)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
