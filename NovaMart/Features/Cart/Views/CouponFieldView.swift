import SwiftUI

struct CouponFieldView: View {
    @Bindable var viewModel: CartViewModel
    @Environment(AppState.self) private var appState
    @FocusState private var isFocused: Bool
    @State private var showConfetti = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let coupon = viewModel.appliedCoupon {
                // Applied coupon
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundStyle(AppTheme.Colors.success)
                    VStack(alignment: .leading, spacing: 1) {
                        Text(coupon.code)
                            .font(AppTheme.Typography.labelMedium)
                            .foregroundStyle(AppTheme.Colors.success)
                        Text(coupon.description)
                            .font(AppTheme.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button("Remove") {
                        viewModel.removeCoupon()
                    }
                    .font(AppTheme.Typography.labelSmall)
                    .foregroundStyle(AppTheme.Colors.error)
                }
                .padding(AppSpacing.cardPadding)
                .glassCard(tint: AppTheme.Colors.success)
                .overlay(alignment: .top) {
                    ConfettiView(isActive: showConfetti)
                }
                .onAppear { showConfetti = true }
            } else {
                // Input
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)

                    TextField("Coupon code", text: $viewModel.couponCode)
                        .font(AppTheme.Typography.bodyMedium)
                        .textInputAutocapitalization(.characters)
                        .autocorrectionDisabled()
                        .focused($isFocused)
                        .submitLabel(.done)
                        .onSubmit {
                            Task { await viewModel.validateCoupon(appState: appState) }
                        }

                    Button {
                        Task { await viewModel.validateCoupon(appState: appState) }
                    } label: {
                        if viewModel.isValidatingCoupon {
                            ProgressView()
                                .scaleEffect(0.7)
                        } else {
                            Text("Apply")
                                .font(AppTheme.Typography.labelSmall)
                                .foregroundStyle(viewModel.couponCode.isEmpty ? .secondary : AppTheme.Colors.primary)
                        }
                    }
                    .disabled(viewModel.couponCode.isEmpty || viewModel.isValidatingCoupon)
                }
                .padding(.horizontal, AppSpacing.md)
                .frame(height: AppSpacing.inputHeight)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                        .strokeBorder(
                            viewModel.couponError != nil
                                ? AppTheme.Colors.error.opacity(0.6)
                                : (isFocused ? AppTheme.Colors.primary.opacity(0.5) : .white.opacity(0.15)),
                            lineWidth: viewModel.couponError != nil || isFocused ? 1.5 : 0.5
                        )
                }

                if let error = viewModel.couponError {
                    Label(error, systemImage: "exclamationmark.circle.fill")
                        .font(AppTheme.Typography.caption)
                        .foregroundStyle(AppTheme.Colors.error)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .animation(.snappy, value: viewModel.appliedCoupon?.id)
        .animation(.snappy, value: viewModel.couponError)
    }
}
