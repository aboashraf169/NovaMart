import SwiftUI

struct CustomerListView: View {
    let customers: [DemoCustomer] = DemoCustomer.samples

    var body: some View {
        ScrollView {
            LazyVStack(spacing: AppSpacing.sm) {
                ForEach(customers) { customer in
                    CustomerRow(customer: customer)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Customers")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct CustomerRow: View {
    let customer: DemoCustomer

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Circle()
                .fill(AppTheme.Colors.primaryGradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(customer.initials)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(customer.name).font(AppTheme.Typography.labelMedium)
                Text(customer.email).font(AppTheme.Typography.caption).foregroundStyle(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(customer.orderCount) orders")
                    .font(AppTheme.Typography.caption)
                    .foregroundStyle(.secondary)
                Text(customer.totalSpent.formatted)
                    .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    .foregroundStyle(AppTheme.Colors.primary)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard()
    }
}

struct DemoCustomer: Identifiable {
    let id = UUID()
    let name: String
    let email: String
    let orderCount: Int
    let totalSpent: Decimal

    var initials: String {
        let parts = name.split(separator: " ")
        return parts.count >= 2 ? "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased() : String(name.prefix(2)).uppercased()
    }

    static let samples: [DemoCustomer] = [
        DemoCustomer(name: "Alex Johnson", email: "alex@example.com", orderCount: 12, totalSpent: 1284.50),
        DemoCustomer(name: "Sarah Mitchell", email: "sarah@example.com", orderCount: 8, totalSpent: 892.00),
        DemoCustomer(name: "James Kim", email: "james@example.com", orderCount: 23, totalSpent: 3421.75),
        DemoCustomer(name: "Priya Patel", email: "priya@example.com", orderCount: 5, totalSpent: 456.20),
        DemoCustomer(name: "Marcus Chen", email: "marcus@example.com", orderCount: 17, totalSpent: 2103.90)
    ]
}
