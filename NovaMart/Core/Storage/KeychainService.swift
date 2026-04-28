import Foundation
import Security

final class KeychainService: @unchecked Sendable {
    static let shared = KeychainService()
    private let service = "com.novamart.app"

    private init() {}

    enum Key: String {
        case authToken = "auth_token"
        case refreshToken = "refresh_token"
        case userID = "user_id"
    }

    func save(key: Key, value: String) throws {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    func retrieve(key: Key) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.notFound
        }

        guard let string = String(data: data, encoding: .utf8) else {
            throw KeychainError.invalidData
        }

        return string
    }

    func delete(key: Key) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key.rawValue
        ]

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    func deleteAll() throws {
        for key in [Key.authToken, .refreshToken, .userID] {
            try? delete(key: key)
        }
    }
}

enum KeychainError: LocalizedError {
    case saveFailed(OSStatus)
    case notFound
    case invalidData
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .saveFailed(let status): return "Keychain save failed: \(status)"
        case .notFound: return "Keychain item not found"
        case .invalidData: return "Keychain data is invalid"
        case .deleteFailed(let status): return "Keychain delete failed: \(status)"
        }
    }
}
