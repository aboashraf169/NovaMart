import SwiftUI
import LocalAuthentication

struct BiometricPromptView: View {
    let onAuthenticated: () -> Void
    let onSkip: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var biometricType: LABiometryType = .none
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var didAttempt = false

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                Spacer()

                VStack(spacing: AppSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.Colors.primaryGradient)
                            .frame(width: 100, height: 100)
                            .shadow(color: AppTheme.Colors.primary.opacity(0.4), radius: 20, y: 8)

                        Image(systemName: biometricType == .faceID ? "faceid" : "touchid")
                            .font(.system(size: 44))
                            .foregroundStyle(.white)
                            .symbolEffect(.pulse, isActive: isAuthenticating)
                    }

                    VStack(spacing: AppSpacing.sm) {
                        Text("Enable \(biometricType == .faceID ? "Face ID" : "Touch ID")")
                            .font(AppTheme.Typography.title2)

                        Text("Sign in faster and more securely using \(biometricType == .faceID ? "Face ID" : "Touch ID") instead of your password.")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                if let error = errorMessage {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(AppTheme.Colors.warning)
                        Text(error)
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundStyle(AppTheme.Colors.warning)
                    }
                    .padding(AppSpacing.md)
                    .glassCard(tint: AppTheme.Colors.warning)
                    .transition(.scale.combined(with: .opacity))
                }

                VStack(spacing: AppSpacing.md) {
                    GlassButton("Enable \(biometricType == .faceID ? "Face ID" : "Touch ID")") {
                        authenticate()
                    }
                    .disabled(isAuthenticating)

                    Button("Not Now") {
                        onSkip()
                    }
                    .font(AppTheme.Typography.bodyMedium)
                    .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Text("Your biometric data never leaves your device.")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, AppSpacing.lg)
            }
            .padding(.horizontal, AppSpacing.screenPadding)
            .background(AnimatedMeshBackground())
            .navigationBarHidden(true)
        }
        .onAppear { detectBiometricType() }
    }

    private func detectBiometricType() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            biometricType = context.biometryType
        }
    }

    private func authenticate() {
        withAnimation(.smooth) { errorMessage = nil }
        isAuthenticating = true
        HapticService.shared.play(.impact(.medium))

        let context = LAContext()
        let reason = "Authenticate to enable quick sign-in for NovaMart"

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, error in
            Task { @MainActor in
                isAuthenticating = false
                if success {
                    HapticService.shared.play(.notification(.success))
                    onAuthenticated()
                } else {
                    withAnimation(.smooth) {
                        if let error = error as? LAError {
                            switch error.code {
                            case .userCancel, .appCancel:
                                errorMessage = nil
                            case .biometryNotEnrolled:
                                errorMessage = "No biometrics enrolled. Please set up Face ID in Settings."
                            case .biometryLockout:
                                errorMessage = "Biometrics locked. Please use your passcode first."
                            default:
                                errorMessage = "Authentication failed. Please try again."
                            }
                        }
                    }
                    if errorMessage != nil {
                        HapticService.shared.play(.notification(.error))
                    }
                }
            }
        }
    }
}
