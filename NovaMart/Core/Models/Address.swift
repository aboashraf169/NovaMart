import Foundation

struct Address: Identifiable, Codable, Sendable, Hashable {
    let id: UUID
    var label: String
    var firstName: String
    var lastName: String
    var line1: String
    var line2: String?
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var phone: String?
    var isDefault: Bool

    var fullName: String { "\(firstName) \(lastName)" }

    var formatted: String {
        var parts = [line1]
        if let l2 = line2, !l2.isEmpty { parts.append(l2) }
        parts.append("\(city), \(state) \(postalCode)")
        parts.append(country)
        return parts.joined(separator: "\n")
    }

    var singleLine: String {
        var parts = [line1]
        if let l2 = line2, !l2.isEmpty { parts.append(l2) }
        parts.append(city)
        return parts.joined(separator: ", ")
    }

    static let sample = Address(
        id: UUID(),
        label: "Home",
        firstName: "Alex",
        lastName: "Johnson",
        line1: "123 Main Street",
        line2: "Apt 4B",
        city: "San Francisco",
        state: "CA",
        postalCode: "94102",
        country: "United States",
        phone: "+1 (415) 555-0100",
        isDefault: true
    )
}
