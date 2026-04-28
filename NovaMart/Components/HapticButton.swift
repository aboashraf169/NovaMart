import SwiftUI

struct HapticButton<Label: View>: View {
    let feedback: HapticService.FeedbackType
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    init(
        feedback: HapticService.FeedbackType = .impact(.medium),
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.feedback = feedback
        self.action = action
        self.label = label
    }

    var body: some View {
        Button {
            HapticService.shared.play(feedback)
            action()
        } label: {
            label()
        }
        .buttonStyle(ScalePressEffect())
    }
}

// MARK: - Wishlist Heart Button
struct WishlistButton: View {
    let productID: UUID
    @Environment(AppState.self) private var appState
    @State private var isAnimating = false

    var isActive: Bool { appState.isWishlisted(productID) }

    var body: some View {
        Button {
            withAnimation(.elastic) {
                isAnimating = true
                appState.toggleWishlist(productID: productID)
            }
            Task {
                try? await Task.sleep(for: .milliseconds(300))
                await MainActor.run { isAnimating = false }
            }
        } label: {
            Image(systemName: isActive ? "heart.fill" : "heart")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(isActive ? Color.red : .white)
                .frame(width: 36, height: 36)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(Circle().strokeBorder(.white.opacity(0.2), lineWidth: 0.5))
                .scaleEffect(isAnimating ? 1.3 : 1.0)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isActive ? "Remove from wishlist" : "Add to wishlist")
        .accessibilityAddTraits(.isButton)
    }
}
