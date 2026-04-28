import SwiftUI

struct RegisterView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(AppState.self) private var appState
    @State private var showPassword = false
    @State private var showConfirmPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                AuthField(
                    title: "Full Name",
                    text: $viewModel.name,
                    icon: "person.fill",
                    type: .name
                ) { viewModel.clearError(for: "name") }

                AuthField(
                    title: "Email",
                    text: $viewModel.email,
                    icon: "envelope.fill",
                    type: .emailAddress,
                    error: viewModel.validationErrors["email"]
                ) { viewModel.clearError(for: "email") }

                AuthField(
                    title: "Password",
                    text: $viewModel.password,
                    icon: "lock.fill",
                    type: .newPassword,
                    isSecure: !showPassword,
                    trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                    error: viewModel.validationErrors["password"],
                    trailingAction: { showPassword.toggle() }
                ) { viewModel.clearError(for: "password") }

                // Password strength
                if !viewModel.password.isEmpty {
                    PasswordStrengthView(password: viewModel.password)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }

                AuthField(
                    title: "Confirm Password",
                    text: $viewModel.confirmPassword,
                    icon: "lock.fill",
                    type: .newPassword,
                    isSecure: !showConfirmPassword,
                    trailingIcon: showConfirmPassword ? "eye.slash.fill" : "eye.fill",
                    error: viewModel.validationErrors["confirmPassword"],
                    trailingAction: { showConfirmPassword.toggle() }
                ) { viewModel.clearError(for: "confirmPassword") }

                // Terms
                Text("By creating an account, you agree to our **Terms of Service** and **Privacy Policy**.")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                GlassButton(
                    "Create Account",
                    icon: "checkmark",
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.register(appState: appState) }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .animation(.snappy, value: viewModel.password.isEmpty)
        }
    }
}

struct PasswordStrengthView: View {
    let password: String

    private var strength: Int {
        var score = 0
        if password.count >= 8 { score += 1 }
        if password.contains(where: \.isUppercase) { score += 1 }
        if password.contains(where: \.isNumber) { score += 1 }
        if password.count >= 12 { score += 1 }
        return score
    }

    private var label: String {
        switch strength {
        case 0, 1: "Weak"
        case 2: "Fair"
        case 3: "Good"
        default: "Strong"
        }
    }

    private var color: Color {
        switch strength {
        case 0, 1: AppTheme.Colors.error
        case 2: AppTheme.Colors.warning
        case 3: AppTheme.Colors.secondary
        default: Color(hex: "#34C759")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text("Password strength")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(label)
                    .font(AppTheme.Typography.captionBold)
                    .foregroundStyle(color)
            }

            HStack(spacing: 4) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(i < strength ? color : Color(UIColor.systemGray5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 4)
                        .animation(.snappy.delay(Double(i) * 0.05), value: strength)
                }
            }
        }
    }
}
