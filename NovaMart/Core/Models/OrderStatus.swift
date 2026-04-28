import SwiftUI
import Charts

enum OrderStatus: String, Codable, CaseIterable, Sendable, Plottable {
    case pending
    case paymentPending
    case confirmed
    case processing
    case packed
    case shipped
    case outForDelivery
    case delivered
    case cancelled
    case returnRequested
    case returned
    case refunded

    var displayName: String {
        switch self {
        case .pending: "Pending"
        case .paymentPending: "Payment Pending"
        case .confirmed: "Confirmed"
        case .processing: "Processing"
        case .packed: "Packed"
        case .shipped: "Shipped"
        case .outForDelivery: "Out for Delivery"
        case .delivered: "Delivered"
        case .cancelled: "Cancelled"
        case .returnRequested: "Return Requested"
        case .returned: "Returned"
        case .refunded: "Refunded"
        }
    }

    var icon: String {
        switch self {
        case .pending: "clock.fill"
        case .paymentPending: "creditcard.fill"
        case .confirmed: "checkmark.circle.fill"
        case .processing: "gearshape.fill"
        case .packed: "shippingbox.fill"
        case .shipped: "airplane.departure"
        case .outForDelivery: "bicycle"
        case .delivered: "house.fill"
        case .cancelled: "xmark.circle.fill"
        case .returnRequested: "arrow.uturn.left.circle.fill"
        case .returned: "arrow.uturn.left.circle"
        case .refunded: "dollarsign.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .pending, .paymentPending: Color(hex: "#FF9F0A")
        case .confirmed, .processing, .packed: AppTheme.Colors.primary
        case .shipped, .outForDelivery: AppTheme.Colors.secondary
        case .delivered: Color(hex: "#34C759")
        case .cancelled, .returnRequested, .returned, .refunded: Color(hex: "#FF3B30")
        }
    }

    var progress: Double {
        switch self {
        case .pending: 0.05
        case .paymentPending: 0.1
        case .confirmed: 0.2
        case .processing: 0.35
        case .packed: 0.5
        case .shipped: 0.65
        case .outForDelivery: 0.85
        case .delivered: 1.0
        case .cancelled, .returnRequested, .returned, .refunded: 0
        }
    }

    var isTerminal: Bool {
        [.delivered, .cancelled, .refunded].contains(self)
    }

    var isActive: Bool {
        [.confirmed, .processing, .packed, .shipped, .outForDelivery].contains(self)
    }
}

enum PaymentStatus: String, Codable, CaseIterable, Sendable {
    case pending, processing, paid, failed, refunded, partialRefund

    var displayName: String {
        switch self {
        case .pending: "Pending"
        case .processing: "Processing"
        case .paid: "Paid"
        case .failed: "Failed"
        case .refunded: "Refunded"
        case .partialRefund: "Partial Refund"
        }
    }

    var color: Color {
        switch self {
        case .pending, .processing: Color(hex: "#FF9F0A")
        case .paid: Color(hex: "#34C759")
        case .failed: Color(hex: "#FF3B30")
        case .refunded, .partialRefund: AppTheme.Colors.primary
        }
    }
}
