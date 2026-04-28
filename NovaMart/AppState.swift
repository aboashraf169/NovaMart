import SwiftUI
import Observation

@Observable
@MainActor
final class AppState {
    // MARK: - Auth
    var currentUser: User?
    var isAuthenticated: Bool = false
    var hasCompletedOnboarding: Bool = false

    // MARK: - Navigation
    var selectedTab: Tab = .home
    var navigationPath = NavigationPath()

    // MARK: - Cart
    var cartItems: [CartItem] = []
    var cartItemCount: Int { cartItems.reduce(0) { $0 + $1.quantity } }
    var cartTotal: Decimal { cartItems.reduce(0) { $0 + ($1.product.price * Decimal($1.quantity)) } }

    // MARK: - Wishlist
    var wishlistIDs: Set<UUID> = []

    // MARK: - Notifications
    var notificationCount: Int = 0
    var toast: ToastMessage? = nil

    // MARK: - Admin
    var isAdmin: Bool {
        if currentUser?.role == .admin { return true }
        return UserDefaults.standard.string(forKey: "userRole") == "admin"
    }

    // MARK: - Preferences
    var preferredColorScheme: ColorScheme? = nil

    // MARK: - Language
    enum AppLanguage: String, CaseIterable {
        case english = "en"
        case arabic = "ar"

        var displayName: String {
            switch self {
            case .english: return "English"
            case .arabic: return "العربية"
            }
        }

        var locale: Locale { Locale(identifier: rawValue) }

        var layoutDirection: LayoutDirection {
            self == .arabic ? .rightToLeft : .leftToRight
        }
    }

    var language: AppLanguage = {
        let saved = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        return AppLanguage(rawValue: saved) ?? .english
    }()

    func setLanguage(_ lang: AppLanguage) {
        language = lang
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
    }

    // MARK: - Init
    init() {
        // Clear any stale session data to force fresh login
        try? KeychainService.shared.delete(key: .authToken)
        UserDefaults.standard.removeObject(forKey: "userRole")
        restoreSession()
    }

    // MARK: - Session
    private func restoreSession() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        // Only restore session if userRole is also saved (new sessions include role)
        // This clears any old sessions that pre-date role persistence
        guard UserDefaults.standard.string(forKey: "userRole") != nil else {
            try? KeychainService.shared.delete(key: .authToken)
            return
        }
        if let token = try? KeychainService.shared.retrieve(key: .authToken),
           !token.isEmpty {
            isAuthenticated = true
        }
    }

    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        withAnimation(.smooth) {
            hasCompletedOnboarding = true
        }
    }

    func signIn(user: User) {
        currentUser = user
        UserDefaults.standard.set(user.role.rawValue, forKey: "userRole")
        withAnimation(.smooth) {
            isAuthenticated = true
        }
    }

    func signOut() {
        try? KeychainService.shared.delete(key: .authToken)
        UserDefaults.standard.removeObject(forKey: "userRole")
        currentUser = nil
        cartItems = []
        wishlistIDs = []
        withAnimation(.smooth) {
            isAuthenticated = false
            selectedTab = .home
        }
    }

    // MARK: - Cart
    func addToCart(_ product: Product, variant: ProductVariant? = nil, quantity: Int = 1) {
        if let idx = cartItems.firstIndex(where: {
            $0.product.id == product.id && $0.variant?.id == variant?.id
        }) {
            cartItems[idx].quantity += quantity
        } else {
            cartItems.append(CartItem(product: product, variant: variant, quantity: quantity))
        }
        showToast("Added to cart", style: .success)
        HapticService.shared.play(.impact(.heavy))
    }

    func removeFromCart(id: UUID) {
        cartItems.removeAll { $0.id == id }
    }

    func clearCart() {
        cartItems = []
    }

    // MARK: - Wishlist
    func toggleWishlist(productID: UUID) {
        if wishlistIDs.contains(productID) {
            wishlistIDs.remove(productID)
            HapticService.shared.play(.impact(.medium))
        } else {
            wishlistIDs.insert(productID)
            HapticService.shared.play(.impact(.medium))
        }
    }

    func isWishlisted(_ productID: UUID) -> Bool {
        wishlistIDs.contains(productID)
    }

    // MARK: - Toast
    func showToast(_ message: String, style: ToastMessage.Style = .info) {
        toast = ToastMessage(message: message, style: style)
    }

    // MARK: - Deep Linking
    func handleDeepLink(_ url: URL) {
        guard url.scheme == "novamart" else { return }
        let host = url.host
        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch host {
        case "product":
            if let idString = pathComponents.first,
               let id = UUID(uuidString: idString) {
                selectedTab = .home
                // Deep link navigation handled by NavigationStack
                NotificationCenter.default.post(
                    name: .navigateToProduct,
                    object: id
                )
            }
        case "cart":
            selectedTab = .cart
        case "orders":
            selectedTab = .orders
        case "profile":
            selectedTab = .profile
        default:
            break
        }
    }
}

// MARK: - Tab
enum Tab: String, CaseIterable, Hashable {
    case home, search, wishlist, cart, orders, profile
}

// MARK: - Toast Message
struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let message: String
    let style: Style
    let duration: Double

    init(message: String, style: Style = .info, duration: Double = 3.0) {
        self.message = message
        self.style = style
        self.duration = duration
    }

    enum Style {
        case success, error, warning, info

        var icon: String {
            switch self {
            case .success: "checkmark.circle.fill"
            case .error: "xmark.circle.fill"
            case .warning: "exclamationmark.triangle.fill"
            case .info: "info.circle.fill"
            }
        }

        var color: Color {
            switch self {
            case .success: AppTheme.Colors.success
            case .error: AppTheme.Colors.error
            case .warning: AppTheme.Colors.warning
            case .info: AppTheme.Colors.primary
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let navigateToProduct = Notification.Name("navigateToProduct")
}
