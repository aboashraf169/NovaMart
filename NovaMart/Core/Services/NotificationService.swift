import Foundation
import UserNotifications

@MainActor
final class NotificationService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationService()

    private let center = UNUserNotificationCenter.current()

    override private init() {
        super.init()
        center.delegate = self
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }

    func scheduleOrderUpdate(orderNumber: String, status: OrderStatus, delay: TimeInterval = 2) {
        let content = UNMutableNotificationContent()
        content.title = "Order \(orderNumber)"
        content.body = status.notificationBody
        content.sound = .default
        content.userInfo = ["order_number": orderNumber, "status": status.rawValue]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 0.1), repeats: false)
        let request = UNNotificationRequest(
            identifier: "order_\(orderNumber)_\(status.rawValue)",
            content: content,
            trigger: trigger
        )
        center.add(request)
    }

    func scheduleFlashSaleReminder(productName: String, startDate: Date) {
        guard startDate > Date.now else { return }
        let content = UNMutableNotificationContent()
        content.title = "Flash Sale Starting!"
        content.body = "\(productName) and more — limited time only. Tap to shop now."
        content.sound = .default

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "flash_\(productName)", content: content, trigger: trigger)
        center.add(request)
    }

    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }
}

private extension OrderStatus {
    var notificationBody: String {
        switch self {
        case .confirmed: return "Your order has been confirmed and is being prepared."
        case .processing: return "Your order is being processed."
        case .shipped: return "Your order is on its way!"
        case .outForDelivery: return "Your order is out for delivery today."
        case .delivered: return "Your order has been delivered. Enjoy!"
        case .cancelled: return "Your order has been cancelled."
        case .refunded: return "Your refund has been processed."
        default: return "Your order status has been updated."
        }
    }
}
