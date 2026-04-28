import SwiftUI

struct ToastView: View {
    @Environment(AppState.self) private var appState
    @State private var dismissTask: Task<Void, Never>? = nil

    var body: some View {
        @Bindable var state = appState

        if let toast = appState.toast {
            HStack(spacing: AppSpacing.sm) {
                Image(systemName: toast.style.icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(toast.style.color)

                Text(toast.message)
                    .font(AppTheme.Typography.bodySmall)
                    .foregroundStyle(.primary)

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm + 4)
            .glassCard(cornerRadius: AppTheme.Radius.button)
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.bottom, AppSpacing.lg)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .id(toast.id)
            .onAppear {
                scheduleAutoDismiss(duration: toast.duration)
            }
        }
    }

    private func dismiss() {
        withAnimation(.snappy) {
            appState.toast = nil
        }
        dismissTask?.cancel()
    }

    private func scheduleAutoDismiss(duration: Double) {
        dismissTask?.cancel()
        dismissTask = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(.snappy) {
                    appState.toast = nil
                }
            }
        }
    }
}
