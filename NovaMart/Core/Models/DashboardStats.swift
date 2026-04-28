import Foundation

struct DashboardStats: Codable, Sendable {
    // Revenue
    var totalRevenue: Decimal
    var revenueToday: Decimal
    var revenueGrowth: Double
    var revenueByDay: [DayRevenue]
    var revenueByMonth: [MonthRevenue]

    // Orders
    var totalOrders: Int
    var ordersToday: Int
    var ordersGrowth: Double
    var ordersByStatus: [StatusCount]
    var avgOrderValue: Decimal

    // Products
    var totalProducts: Int
    var activeProducts: Int
    var lowStockCount: Int
    var outOfStockCount: Int
    var topSellingProducts: [ProductStat]

    // Customers
    var totalCustomers: Int
    var newCustomersToday: Int
    var returningCustomerRate: Double

    // Conversions
    var conversionRate: Double
    var cartAbandonmentRate: Double
    var avgRating: Double

    static let sample = DashboardStats(
        totalRevenue: 284_920.50,
        revenueToday: 4_312.80,
        revenueGrowth: 12.4,
        revenueByDay: (0..<30).map { i in
            DayRevenue(
                date: Date.now.addingTimeInterval(-Double(i) * 86400),
                revenue: Decimal(Double.random(in: 2000...8000)),
                orderCount: Int.random(in: 30...120)
            )
        }.reversed(),
        revenueByMonth: (0..<12).map { i in
            MonthRevenue(
                month: Calendar.current.date(byAdding: .month, value: -i, to: Date.now) ?? Date.now,
                revenue: Decimal(Double.random(in: 18000...45000))
            )
        }.reversed(),
        totalOrders: 3_847,
        ordersToday: 48,
        ordersGrowth: 8.2,
        ordersByStatus: [
            StatusCount(status: .pending, count: 12),
            StatusCount(status: .processing, count: 34),
            StatusCount(status: .shipped, count: 89),
            StatusCount(status: .delivered, count: 3421),
            StatusCount(status: .cancelled, count: 291)
        ],
        avgOrderValue: 74.07,
        totalProducts: 1_247,
        activeProducts: 1_189,
        lowStockCount: 34,
        outOfStockCount: 12,
        topSellingProducts: [
            ProductStat(productName: "Pro Wireless Headphones", unitsSold: 342, revenue: 102_297.58),
            ProductStat(productName: "Merino Wool Sweater", unitsSold: 289, revenue: 36_125.00),
            ProductStat(productName: "Yoga Mat Pro", unitsSold: 245, revenue: 19_110.00),
            ProductStat(productName: "Leather Crossbody Bag", unitsSold: 187, revenue: 35_343.00),
            ProductStat(productName: "Ceramic Pour-Over Set", unitsSold: 156, revenue: 13_884.00)
        ],
        totalCustomers: 12_483,
        newCustomersToday: 23,
        returningCustomerRate: 0.34,
        conversionRate: 0.032,
        cartAbandonmentRate: 0.68,
        avgRating: 4.6
    )
}

struct DayRevenue: Codable, Sendable, Identifiable {
    var id: Date { date }
    var date: Date
    var revenue: Decimal
    var orderCount: Int
}

struct MonthRevenue: Codable, Sendable, Identifiable {
    var id: Date { month }
    var month: Date
    var revenue: Decimal
}

struct StatusCount: Codable, Sendable, Identifiable {
    var id: OrderStatus { status }
    var status: OrderStatus
    var count: Int
}

struct ProductStat: Codable, Sendable, Identifiable {
    var id: String { productName }
    var productName: String
    var unitsSold: Int
    var revenue: Decimal
}

enum DashboardPeriod: String, Codable, CaseIterable, Sendable {
    case today, week, month, custom

    var displayName: String {
        switch self {
        case .today: "Today"
        case .week: "7 Days"
        case .month: "30 Days"
        case .custom: "Custom"
        }
    }
}
