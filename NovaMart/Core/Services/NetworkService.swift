import Foundation

// MARK: - Network Service
struct NetworkService: Sendable {
    static let shared = NetworkService()
    private let baseURL = URL(string: "https://api.novamart.app/v1")!
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 120
        config.waitsForConnectivity = true
        config.httpAdditionalHeaders = ["Accept": "application/json"]
        session = URLSession(configuration: config)
    }

    func fetch<T: Decodable & Sendable>(
        _ endpoint: Endpoint,
        as type: T.Type = T.self
    ) async throws -> T {
        let request = try await buildRequest(for: endpoint)
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch http.statusCode {
        case 200...299:
            break
        case 401:
            throw AppError.unauthorized
        case 403:
            throw AppError.forbidden
        case 404:
            throw AppError.notFound
        case 422:
            let validationError = (try? JSONDecoder.api.decode(ValidationError.self, from: data))
                ?? ValidationError(message: "Validation failed", fields: nil)
            throw AppError.validation(validationError)
        default:
            throw AppError.serverError(http.statusCode)
        }

        do {
            return try JSONDecoder.api.decode(T.self, from: data)
        } catch let decoding as DecodingError {
            throw AppError.decodingError(decoding.localizedDescription)
        }
    }

    func upload<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        _ endpoint: Endpoint,
        body: Body,
        as type: Response.Type = Response.self
    ) async throws -> Response {
        var request = try await buildRequest(for: endpoint)
        request.httpBody = try JSONEncoder.api.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }

        switch http.statusCode {
        case 200...299: break
        case 401: throw AppError.unauthorized
        case 403: throw AppError.forbidden
        case 404: throw AppError.notFound
        case 422:
            let err = (try? JSONDecoder.api.decode(ValidationError.self, from: data))
                ?? ValidationError(message: "Validation failed", fields: nil)
            throw AppError.validation(err)
        default: throw AppError.serverError(http.statusCode)
        }

        do {
            return try JSONDecoder.api.decode(Response.self, from: data)
        } catch let decoding as DecodingError {
            throw AppError.decodingError(decoding.localizedDescription)
        }
    }

    // MARK: - Private
    private func buildRequest(for endpoint: Endpoint) async throws -> URLRequest {
        let url = try endpoint.url(baseURL: baseURL)
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method

        if let token = try? KeychainService.shared.retrieve(key: .authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
}

// MARK: - Endpoint
enum Endpoint: Sendable {
    // Auth
    case login(email: String, password: String)
    case register(name: String, email: String, password: String)
    case logout
    case refreshToken
    case forgotPassword(email: String)
    case resetPassword(token: String, password: String)
    case verifyOTP(email: String, code: String)

    // Products
    case products(page: Int, filter: SearchFilter?)
    case productDetail(id: UUID)
    case createProduct(name: String)
    case updateProduct(id: UUID)
    case deleteProduct(id: UUID)
    case featuredProducts
    case flashSaleProducts
    case relatedProducts(id: UUID)

    // Cart
    case cart
    case addToCart(productID: UUID, variantID: UUID?, quantity: Int)
    case updateCartItem(id: UUID, quantity: Int)
    case removeFromCart(id: UUID)
    case clearCart

    // Orders
    case orders(page: Int, status: OrderStatus?)
    case orderDetail(id: UUID)
    case createOrder
    case updateOrderStatus(id: UUID, status: OrderStatus)
    case cancelOrder(id: UUID)

    // Reviews
    case reviews(productID: UUID, page: Int)
    case createReview(productID: UUID)

    // Search
    case search(query: String, page: Int)
    case searchSuggestions(query: String)

    // User
    case profile
    case updateProfile
    case addresses
    case addAddress
    case updateAddress(id: UUID)
    case deleteAddress(id: UUID)
    case paymentMethods
    case deletePaymentMethod(id: UUID)

    // Admin
    case dashboard(period: DashboardPeriod)
    case adminProducts(page: Int)
    case adminOrders(page: Int, status: OrderStatus?)
    case customers(page: Int)
    case coupons
    case createCoupon
    case updateCoupon(id: UUID)
    case deleteCoupon(id: UUID)

    // Wishlist
    case wishlist
    case addToWishlist(productID: UUID)
    case removeFromWishlist(productID: UUID)

    var method: String {
        switch self {
        case .login, .register, .forgotPassword, .resetPassword, .verifyOTP,
             .addToCart, .createOrder, .createReview, .addAddress,
             .addToWishlist, .createProduct, .createCoupon:
            return "POST"
        case .updateProduct, .updateCartItem, .updateOrderStatus, .updateProfile,
             .updateAddress, .updateCoupon:
            return "PUT"
        case .deleteProduct, .deleteAddress, .deletePaymentMethod, .removeFromCart,
             .clearCart, .removeFromWishlist, .deleteCoupon, .logout:
            return "DELETE"
        default:
            return "GET"
        }
    }

    func url(baseURL: URL) throws -> URL {
        switch self {
        case .login: return baseURL.appending(path: "auth/login")
        case .register: return baseURL.appending(path: "auth/register")
        case .logout: return baseURL.appending(path: "auth/logout")
        case .refreshToken: return baseURL.appending(path: "auth/refresh")
        case .forgotPassword: return baseURL.appending(path: "auth/forgot-password")
        case .resetPassword: return baseURL.appending(path: "auth/reset-password")
        case .verifyOTP: return baseURL.appending(path: "auth/verify-otp")
        case .products(let page, _):
            return baseURL.appending(path: "products").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .productDetail(let id): return baseURL.appending(path: "products/\(id.uuidString)")
        case .createProduct: return baseURL.appending(path: "products")
        case .updateProduct(let id): return baseURL.appending(path: "products/\(id.uuidString)")
        case .deleteProduct(let id): return baseURL.appending(path: "products/\(id.uuidString)")
        case .featuredProducts: return baseURL.appending(path: "products/featured")
        case .flashSaleProducts: return baseURL.appending(path: "products/flash-sale")
        case .relatedProducts(let id): return baseURL.appending(path: "products/\(id.uuidString)/related")
        case .cart: return baseURL.appending(path: "cart")
        case .addToCart: return baseURL.appending(path: "cart/items")
        case .updateCartItem(let id, _): return baseURL.appending(path: "cart/items/\(id.uuidString)")
        case .removeFromCart(let id): return baseURL.appending(path: "cart/items/\(id.uuidString)")
        case .clearCart: return baseURL.appending(path: "cart")
        case .orders(let page, _):
            return baseURL.appending(path: "orders").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .orderDetail(let id): return baseURL.appending(path: "orders/\(id.uuidString)")
        case .createOrder: return baseURL.appending(path: "orders")
        case .updateOrderStatus(let id, _): return baseURL.appending(path: "orders/\(id.uuidString)/status")
        case .cancelOrder(let id): return baseURL.appending(path: "orders/\(id.uuidString)/cancel")
        case .reviews(let productID, let page):
            return baseURL.appending(path: "products/\(productID.uuidString)/reviews").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .createReview(let productID): return baseURL.appending(path: "products/\(productID.uuidString)/reviews")
        case .search(let q, let page):
            return baseURL.appending(path: "search").appending(queryItems: [URLQueryItem(name: "q", value: q), URLQueryItem(name: "page", value: "\(page)")])
        case .searchSuggestions(let q):
            return baseURL.appending(path: "search/suggestions").appending(queryItems: [URLQueryItem(name: "q", value: q)])
        case .profile: return baseURL.appending(path: "users/me")
        case .updateProfile: return baseURL.appending(path: "users/me")
        case .addresses: return baseURL.appending(path: "users/me/addresses")
        case .addAddress: return baseURL.appending(path: "users/me/addresses")
        case .updateAddress(let id): return baseURL.appending(path: "users/me/addresses/\(id.uuidString)")
        case .deleteAddress(let id): return baseURL.appending(path: "users/me/addresses/\(id.uuidString)")
        case .paymentMethods: return baseURL.appending(path: "users/me/payment-methods")
        case .deletePaymentMethod(let id): return baseURL.appending(path: "users/me/payment-methods/\(id.uuidString)")
        case .dashboard(let period): return baseURL.appending(path: "admin/dashboard").appending(queryItems: [URLQueryItem(name: "period", value: period.rawValue)])
        case .adminProducts(let page): return baseURL.appending(path: "admin/products").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .adminOrders(let page, _): return baseURL.appending(path: "admin/orders").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .customers(let page): return baseURL.appending(path: "admin/customers").appending(queryItems: [URLQueryItem(name: "page", value: "\(page)")])
        case .coupons: return baseURL.appending(path: "admin/coupons")
        case .createCoupon: return baseURL.appending(path: "admin/coupons")
        case .updateCoupon(let id): return baseURL.appending(path: "admin/coupons/\(id.uuidString)")
        case .deleteCoupon(let id): return baseURL.appending(path: "admin/coupons/\(id.uuidString)")
        case .wishlist: return baseURL.appending(path: "users/me/wishlist")
        case .addToWishlist: return baseURL.appending(path: "users/me/wishlist")
        case .removeFromWishlist(let id): return baseURL.appending(path: "users/me/wishlist/\(id.uuidString)")
        }
    }
}

// MARK: - JSON Coders
extension JSONDecoder {
    static let api: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
}

extension JSONEncoder {
    static let api: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
}

// MARK: - URL helpers
private extension URL {
    func appending(path: String) -> URL {
        appendingPathComponent(path)
    }

    func appending(queryItems: [URLQueryItem]) -> URL {
        guard var comps = URLComponents(url: self, resolvingAgainstBaseURL: true) else { return self }
        comps.queryItems = (comps.queryItems ?? []) + queryItems
        return comps.url ?? self
    }
}
