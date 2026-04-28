import SwiftUI

struct NotificationsSettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var prefs = NotificationPreferences()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                GlassCard {
                    VStack(spacing: AppSpacing.md) {
                        NotifToggle(label: "Order Updates", description: "Track your orders in real-time", icon: "shippingbox.fill", color: AppTheme.Colors.secondary, isOn: $prefs.orderUpdates)
                        Divider()
                        NotifToggle(label: "Promotions & Sales", description: "Flash deals, exclusive offers", icon: "tag.fill", color: AppTheme.Colors.accent, isOn: $prefs.promotions)
                        Divider()
                        NotifToggle(label: "Price Drop Alerts", description: "When wishlisted items go on sale", icon: "arrow.down.circle.fill", color: AppTheme.Colors.success, isOn: $prefs.priceDrops)
                        Divider()
                        NotifToggle(label: "New Arrivals", description: "Latest products in your interests", icon: "sparkles", color: AppTheme.Colors.primary, isOn: $prefs.newArrivals)
                        Divider()
                        NotifToggle(label: "System Alerts", description: "Security and account updates", icon: "bell.fill", color: .secondary, isOn: $prefs.systemAlerts)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                GlassButton("Save Preferences") {
                    appState.currentUser?.notificationPreferences = prefs
                    HapticService.shared.play(.notification(.success))
                    appState.showToast("Preferences saved", style: .success)
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            prefs = appState.currentUser?.notificationPreferences ?? NotificationPreferences()
        }
    }
}

struct NotifToggle: View {
    let label: String
    let description: String
    let icon: String
    let color: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 8, style: .continuous).fill(color).frame(width: 32, height: 32)
                Image(systemName: icon).font(.system(size: 14, weight: .semibold)).foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(AppTheme.Typography.bodySmall)
                Text(description).font(AppTheme.Typography.caption).foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .tint(AppTheme.Colors.primary)
                .labelsHidden()
                .onChange(of: isOn) { _, _ in HapticService.shared.play(.impact(.light)) }
        }
    }
}
