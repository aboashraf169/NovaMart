import Foundation

enum AppError: LocalizedError, Sendable {
    case network(URLError)
    case unauthorized
    case forbidden
    case notFound
    case validation(ValidationError)
    case serverError(Int)
    case invalidResponse
    case decodingError(String)
    case storageError(String)
    case unknown(String)

    var errorDescription: String? {
        switch self {
        case .network(let err):
            switch err.code {
            case .notConnectedToInternet: return "No internet connection. Please check your network."
            case .timedOut: return "Request timed out. Please try again."
            case .cannotConnectToHost: return "Cannot connect to server. Please try again later."
            default: return "Network error. Please try again."
            }
        case .unauthorized:
            return "Your session has expired. Please sign in again."
        case .forbidden:
            return "You don't have permission to perform this action."
        case .notFound:
            return "The requested item could not be found."
        case .validation(let err):
            return err.message
        case .serverError(let code):
            return "Server error (\(code)). We're working on it."
        case .invalidResponse:
            return "Received an unexpected response from the server."
        case .decodingError(let detail):
            return "Data error: \(detail)"
        case .storageError(let detail):
            return "Storage error: \(detail)"
        case .unknown(let detail):
            return detail
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .network: return "Check your internet connection and try again."
        case .unauthorized: return "Sign out and sign back in to refresh your session."
        case .forbidden: return "Contact support if you believe this is an error."
        case .notFound: return "The item may have been removed or moved."
        case .serverError: return "Try again in a few minutes."
        default: return "Please try again or contact support."
        }
    }

    var isRetryable: Bool {
        switch self {
        case .network, .serverError, .invalidResponse: return true
        case .unauthorized, .forbidden, .notFound, .validation, .decodingError, .storageError, .unknown: return false
        }
    }
}

struct ValidationError: Codable, Sendable {
    var message: String
    var fields: [String: [String]]?
}
