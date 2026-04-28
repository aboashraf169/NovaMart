import SwiftUI

struct CheckoutContainerView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var selectedAddress: Address? = nil
    @State private var selectedPayment: PaymentMethod? = nil
    @State private var placedOrder: Order? = nil
    @State private var isPlacingOrder = false
    @Namespace private var progressNamespace

    let steps = ["Address", "Payment", "Review"]

    var body: some View {
        NavigationStack {
            ZStack {
                AnimatedMeshBackground()

                VStack(spacing: 0) {
                    // Progress bar
                    CheckoutProgressBar(steps: steps, currentStep: currentStep, namespace: progressNamespace)
                        .padding(AppSpacing.screenPadding)

                    // Step content
                    Group {
                        switch currentStep {
                        case 0:
                            Step1_AddressView(selectedAddress: $selectedAddress)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case 1:
                            Step2_PaymentView(selectedPayment: $selectedPayment)
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                        case 2:
                            Step3_ReviewView(
                                address: selectedAddress,
                                payment: selectedPayment,
                                isPlacing: isPlacingOrder
                            ) {
                                Task { await placeOrder() }
                            }
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                        default:
                            EmptyView()
                        }
                    }
                    .animation(.smooth, value: currentStep)

                    Spacer()

                    // Bottom navigation
                    CheckoutNavBar(
                        currentStep: currentStep,
                        totalSteps: steps.count,
                        canProceed: canProceedFromCurrentStep,
                        isLastStep: currentStep == steps.count - 1
                    ) {
                        if currentStep < steps.count - 1 {
                            withAnimation(.smooth) { currentStep += 1 }
                            HapticService.shared.play(.impact(.medium))
                        }
                    } onBack: {
                        if currentStep > 0 {
                            withAnimation(.smooth) { currentStep -= 1 }
                            HapticService.shared.play(.impact(.light))
                        } else {
                            dismiss()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .fullScreenCover(item: $placedOrder) { order in
                OrderSuccessView(order: order)
            }
        }
        .onAppear {
            selectedAddress = appState.currentUser?.defaultAddress
            selectedPayment = appState.currentUser?.paymentMethods.first(where: { $0.isDefault })
        }
    }

    var canProceedFromCurrentStep: Bool {
        switch currentStep {
        case 0: return selectedAddress != nil
        case 1: return selectedPayment != nil
        case 2: return true
        default: return false
        }
    }

    func placeOrder() async {
        isPlacingOrder = true
        HapticService.shared.play(.impact(.heavy))

        try? await Task.sleep(for: .milliseconds(1500))

        let order = Order.samples[0]
        appState.clearCart()
        HapticService.shared.play(.notification(.success))

        await MainActor.run {
            isPlacingOrder = false
            placedOrder = order
        }
    }
}

struct CheckoutProgressBar: View {
    let steps: [String]
    let currentStep: Int
    let namespace: Namespace.ID

    var body: some View {
        GlassEffectContainer {
            HStack(spacing: 0) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 0) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(index <= currentStep ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(Color(UIColor.systemGray5)))
                                    .frame(width: 28, height: 28)

                                if index < currentStep {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(.white)
                                } else {
                                    Text("\(index + 1)")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundStyle(index == currentStep ? .white : .secondary)
                                }
                            }

                            Text(step)
                                .font(.system(size: 10, weight: index == currentStep ? .semibold : .regular))
                                .foregroundStyle(index <= currentStep ? .primary : .secondary)
                        }

                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < currentStep ? AnyShapeStyle(AppTheme.Colors.primaryGradient) : AnyShapeStyle(Color(UIColor.systemGray5)))
                                .frame(height: 2)
                                .animation(.smooth, value: currentStep)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .glassEffect(in: .capsule)
        }
    }
}

struct CheckoutNavBar: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let isLastStep: Bool
    let onContinue: () -> Void
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Button(action: onBack) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "chevron.left")
                    Text(currentStep == 0 ? "Cancel" : "Back")
                }
                .font(AppTheme.Typography.labelMedium)
                .foregroundStyle(.primary)
                .frame(height: AppSpacing.buttonHeight)
                .padding(.horizontal, AppSpacing.md)
                .glassCard(cornerRadius: AppTheme.Radius.button)
            }
            .buttonStyle(ScalePressEffect())

            GlassButton(
                isLastStep ? "Place Order" : "Continue",
                icon: isLastStep ? "checkmark.seal.fill" : "arrow.right"
            ) {
                onContinue()
            }
            .disabled(!canProceed)
            .opacity(canProceed ? 1 : 0.5)
        }
        .padding(AppSpacing.screenPadding)
        .backgroundExtensionEffect()
    }
}
