import Foundation

protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> User
    func register(name: String, email: String, password: String) async throws -> User
    func logout() async throws
    func refreshToken() async throws -> String
    func resetPassword(email: String) async throws
    func verifyOTP(code: String, destination: String) async throws -> Bool
    func currentUser() async throws -> User?
}

struct AuthService: AuthServiceProtocol {
    private let network: NetworkService
    private let keychain: KeychainService

    init(network: NetworkService = .shared, keychain: KeychainService = .shared) {
        self.network = network
        self.keychain = keychain
    }

    func login(email: String, password: String) async throws -> User {
        // Demo: return a mock user without hitting a real backend
        let user = User(
            id: UUID(),
            name: "Demo User",
            email: email,
            phone: "+1 555-0100",
            avatarURL: nil,
            role: .customer,
            loyaltyPoints: 1_240,
            loyaltyTier: .silver,
            addresses: [],
            defaultAddressID: nil,
            paymentMethods: [],
            defaultPaymentID: nil,
            notificationPreferences: NotificationPreferences(),
            language: "en",
            createdAt: Calendar.current.date(byAdding: .year, value: -1, to: Date.now)!,
            lastLoginAt: Date.now
        )
        try keychain.save(key: .authToken, value: "demo_token_\(UUID())")
        try keychain.save(key: .userID, value: user.id.uuidString)
        return user
    }

    func register(name: String, email: String, password: String) async throws -> User {
        let user = User(
            id: UUID(),
            name: name,
            email: email,
            phone: nil,
            avatarURL: nil,
            role: .customer,
            loyaltyPoints: 100,
            loyaltyTier: .bronze,
            addresses: [],
            defaultAddressID: nil,
            paymentMethods: [],
            defaultPaymentID: nil,
            notificationPreferences: NotificationPreferences(),
            language: "en",
            createdAt: Date.now,
            lastLoginAt: Date.now
        )
        try keychain.save(key: .authToken, value: "demo_token_\(UUID())")
        try keychain.save(key: .userID, value: user.id.uuidString)
        return user
    }

    func logout() async throws {
        try? keychain.delete(key: .authToken)
        try? keychain.delete(key: .refreshToken)
        try? keychain.delete(key: .userID)
    }

    func refreshToken() async throws -> String {
        let token = "refreshed_token_\(UUID())"
        try keychain.save(key: .authToken, value: token)
        return token
    }

    func resetPassword(email: String) async throws {
        try await Task.sleep(for: .milliseconds(600))
    }

    func verifyOTP(code: String, destination: String) async throws -> Bool {
        try await Task.sleep(for: .milliseconds(800))
        return code != "000000"
    }

    func currentUser() async throws -> User? {
        guard (try? keychain.retrieve(key: .authToken)) != nil else { return nil }
        return nil
    }
}
