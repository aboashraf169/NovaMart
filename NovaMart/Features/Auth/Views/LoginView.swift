import SwiftUI

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    @Environment(AppState.self) private var appState
    @State private var showForgotPassword = false
    @State private var showPassword = false

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Email
                AuthField(
                    title: "Email",
                    text: $viewModel.email,
                    icon: "envelope.fill",
                    type: .emailAddress,
                    error: viewModel.validationErrors["email"]
                ) {
                    viewModel.clearError(for: "email")
                }

                // Password
                AuthField(
                    title: "Password",
                    text: $viewModel.password,
                    icon: "lock.fill",
                    type: .password,
                    isSecure: !showPassword,
                    trailingIcon: showPassword ? "eye.slash.fill" : "eye.fill",
                    error: viewModel.validationErrors["password"],
                    trailingAction: { showPassword.toggle() }
                ) {
                    viewModel.clearError(for: "password")
                }

                // Forgot password
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(AppTheme.Colors.primary)
                }

                // Sign In button
                GlassButton(
                    "Sign In",
                    icon: "arrow.right",
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.login(appState: appState) }
                }

                // Divider
                HStack {
                    Rectangle().fill(.secondary.opacity(0.3)).frame(height: 0.5)
                    Text("or").font(.caption).foregroundStyle(.secondary)
                    Rectangle().fill(.secondary.opacity(0.3)).frame(height: 0.5)
                }

                // Apple sign in / biometric
                Button {
                    Task { await viewModel.loginWithBiometrics(appState: appState) }
                } label: {
                    Label("Sign in with Face ID", systemImage: "faceid")
                        .font(AppTheme.Typography.labelMedium)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: AppSpacing.buttonHeight)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                                .strokeBorder(.white.opacity(0.15), lineWidth: 0.5)
                        }
                }
                .buttonStyle(ScalePressEffect())
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordView(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Auth Field
struct AuthField: View {
    let title: String
    @Binding var text: String
    var icon: String
    var type: UITextContentType
    var isSecure: Bool = false
    var trailingIcon: String? = nil
    var error: String? = nil
    var trailingAction: (() -> Void)? = nil
    var onChange: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(title)
                .font(AppTheme.Typography.labelSmall)
                .foregroundStyle(.secondary)

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                if isSecure {
                    SecureField("", text: $text)
                        .textContentType(type)
                        .font(AppTheme.Typography.bodyLarge)
                        .onChange(of: text) { _, _ in onChange() }
                } else {
                    TextField("", text: $text)
                        .textContentType(type)
                        .keyboardType(type == .emailAddress ? .emailAddress : .default)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(type == .emailAddress ? .never : .sentences)
                        .font(AppTheme.Typography.bodyLarge)
                        .onChange(of: text) { _, _ in onChange() }
                }

                if let trailingIcon, let action = trailingAction {
                    Button(action: action) {
                        Image(systemName: trailingIcon)
                            .font(.system(size: 14))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(height: AppSpacing.inputHeight)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                    .strokeBorder(
                        error != nil ? AppTheme.Colors.error.opacity(0.6) : Color.white.opacity(0.15),
                        lineWidth: error != nil ? 1.5 : 0.5
                    )
            }

            if let error {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(AppTheme.Colors.error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.snappy, value: error)
    }
}
