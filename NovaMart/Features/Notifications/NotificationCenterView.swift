import SwiftUI

@Observable
class NotificationViewModel {
    var notifications: [AppNotification] = AppNotification.samples
    var selectedType: NotificationType? = nil

    var filtered: [AppNotification] {
        guard let type = selectedType else { return notifications }
        return notifications.filter { $0.type == type }
    }

    var unreadCount: Int { notifications.filter { !$0.isRead }.count }

    func markAsRead(_ id: UUID) {
        if let idx = notifications.firstIndex(where: { $0.id == id }) {
            notifications[idx].isRead = true
        }
    }

    func markAllRead() {
        for i in notifications.indices {
            notifications[i].isRead = true
        }
    }

    func delete(_ id: UUID) {
        notifications.removeAll { $0.id == id }
    }
}

struct NotificationCenterView: View {
    @State private var viewModel = NotificationViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Type filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        OrderStatusChip(label: "All", isSelected: viewModel.selectedType == nil) {
                            viewModel.selectedType = nil
                        }
                        ForEach(NotificationType.allCases, id: \.rawValue) { type in
                            OrderStatusChip(label: type.displayName, color: type.color, isSelected: viewModel.selectedType == type) {
                                viewModel.selectedType = type
                                HapticService.shared.play(.selection)
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                // Notifications
                if viewModel.filtered.isEmpty {
                    EmptyStateView(icon: "bell.slash.fill", title: "No Notifications", message: "You're all caught up!")
                } else {
                    ForEach(viewModel.filtered) { notification in
                        NotificationRow(notification: notification) {
                            viewModel.markAsRead(notification.id)
                        } onDelete: {
                            withAnimation(.smooth) { viewModel.delete(notification.id) }
                        }
                        .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
            }
            .padding(.vertical, AppSpacing.md)
        }
        .background(AnimatedMeshBackground())
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.unreadCount > 0 {
                    Button("Mark All Read") {
                        viewModel.markAllRead()
                        HapticService.shared.play(.impact(.light))
                    }
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.primary)
                }
            }
        }
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    let onRead: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 18))
                    .foregroundStyle(notification.type.color)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(notification.title)
                        .font(notification.isRead ? AppTheme.Typography.bodySmall : AppTheme.Typography.labelMedium)
                        .lineLimit(1)

                    if !notification.isRead {
                        Circle()
                            .fill(AppTheme.Colors.primary)
                            .frame(width: 8, height: 8)
                    }

                    Spacer()

                    Text(notification.createdAt.relativeFormatted)
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Text(notification.body)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(AppSpacing.cardPadding)
        .glassCard(tint: notification.isRead ? nil : AppTheme.Colors.primary.opacity(0.03))
        .onTapGesture {
            if !notification.isRead {
                onRead()
                HapticService.shared.play(.impact(.light))
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash.fill")
            }
            if !notification.isRead {
                Button(action: onRead) {
                    Label("Read", systemImage: "checkmark.circle.fill")
                }
                .tint(AppTheme.Colors.primary)
            }
        }
    }
}
