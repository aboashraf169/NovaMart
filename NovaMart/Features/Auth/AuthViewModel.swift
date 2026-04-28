import SwiftUI
import LocalAuthentication
import Observation

@Observable
@MainActor
final class AuthViewModel {
    // Fields
    var name = ""
    var email = ""
    var password = ""
    var confirmPassword = ""
    var otpCode = ""

    // State
    var viewState: ViewState<User> = .idle
    var isLoading = false
    var validationErrors: [String: String] = [:]
    var showBiometric = false

    // Validation
    var isEmailValid: Bool {
        let regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
        return email.contains(regex)
    }

    var isPasswordStrong: Bool {
        password.count >= 8 &&
        password.contains(where: \.isUppercase) &&
        password.contains(where: \.isNumber)
    }

    var passwordsMatch: Bool { password == confirmPassword }

    var canLogin: Bool { isEmailValid && !password.isEmpty && !isLoading }

    var canRegister: Bool {
        !name.isEmpty && isEmailValid && isPasswordStrong && passwordsMatch && !isLoading
    }

    // MARK: - Auth
    func login(appState: AppState) async {
        guard canLogin else {
            validateLoginForm()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            // In production: call AuthService
            // Simulate network delay
            try await Task.sleep(for: .milliseconds(800))
            let user = makeDemoUser(email: email)
            try KeychainService.shared.save(key: .authToken, value: "demo_token_\(UUID().uuidString)")
            appState.signIn(user: user)
            HapticService.shared.play(.notification(.success))
        } catch {
            viewState = .error(AppError.unknown("Login failed. Please check your credentials."))
            HapticService.shared.play(.notification(.error))
        }
    }

    func register(appState: AppState) async {
        guard canRegister else {
            validateRegisterForm()
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await Task.sleep(for: .milliseconds(1000))
            let user = makeDemoUser(name: name, email: email)
            try KeychainService.shared.save(key: .authToken, value: "demo_token_\(UUID().uuidString)")
            appState.signIn(user: user)
            HapticService.shared.play(.notification(.success))
        } catch {
            viewState = .error(AppError.unknown("Registration failed. Please try again."))
            HapticService.shared.play(.notification(.error))
        }
    }

    func loginWithBiometrics(appState: AppState) async {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Sign in to NovaMart"
            )
            if success {
                let user = makeDemoUser()
                try? KeychainService.shared.save(key: .authToken, value: "bio_token_\(UUID().uuidString)")
                appState.signIn(user: user)
                HapticService.shared.play(.notification(.success))
            }
        } catch {
            HapticService.shared.play(.notification(.error))
        }
    }

    func forgotPassword() async -> Bool {
        guard isEmailValid else { return false }
        isLoading = true
        defer { isLoading = false }
        try? await Task.sleep(for: .milliseconds(600))
        return true
    }

    // MARK: - Validation
    private func validateLoginForm() {
        validationErrors = [:]
        if !isEmailValid { validationErrors["email"] = "Please enter a valid email address" }
        if password.isEmpty { validationErrors["password"] = "Password is required" }
        HapticService.shared.play(.notification(.error))
    }

    private func validateRegisterForm() {
        validationErrors = [:]
        if name.isEmpty { validationErrors["name"] = "Name is required" }
        if !isEmailValid { validationErrors["email"] = "Please enter a valid email address" }
        if !isPasswordStrong { validationErrors["password"] = "Password must be 8+ chars with uppercase and number" }
        if !passwordsMatch { validationErrors["confirmPassword"] = "Passwords do not match" }
        HapticService.shared.play(.notification(.error))
    }

    func clearError(for field: String) {
        validationErrors.removeValue(forKey: field)
    }

    // MARK: - Demo user
    private func makeDemoUser(name: String = "Alex Johnson", email: String = "alex@example.com") -> User {
        // Admin credentials: admin@novamart.com / any password
        let resolvedRole: UserRole = email.lowercased() == "admin@novamart.com" ? .admin : .customer
        return User(
            id: UUID(),
            name: resolvedRole == .admin ? "Admin" : name,
            email: email,
            phone: "+1 (415) 555-0100",
            avatarURL: nil,
            role: resolvedRole,
            loyaltyPoints: 1250,
            loyaltyTier: .silver,
            addresses: [Address.sample],
            defaultAddressID: Address.sample.id,
            paymentMethods: [
                PaymentMethod(id: UUID(), type: .applePay, last4: nil, brand: nil, expiryMonth: nil, expiryYear: nil, isDefault: true)
            ],
            defaultPaymentID: nil,
            notificationPreferences: NotificationPreferences(),
            language: "en",
            createdAt: Date.now.addingTimeInterval(-86400 * 180),
            lastLoginAt: Date.now
        )
    }
}
