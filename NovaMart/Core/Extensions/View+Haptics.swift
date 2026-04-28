import SwiftUI

// MARK: - Haptic Service
@MainActor
final class HapticService {
    static let shared = HapticService()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notification = UINotificationFeedbackGenerator()
    private let selection = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notification.prepare()
        selection.prepare()
    }

    enum FeedbackType {
        case impact(UIImpactFeedbackGenerator.FeedbackStyle)
        case notification(UINotificationFeedbackGenerator.FeedbackType)
        case selection
    }

    func play(_ type: FeedbackType) {
        switch type {
        case .impact(let style):
            switch style {
            case .light: impactLight.impactOccurred()
            case .medium: impactMedium.impactOccurred()
            case .heavy: impactHeavy.impactOccurred()
            case .soft: impactLight.impactOccurred(intensity: 0.5)
            case .rigid: impactHeavy.impactOccurred(intensity: 0.8)
            @unknown default: impactMedium.impactOccurred()
            }
        case .notification(let type):
            notification.notificationOccurred(type)
        case .selection:
            selection.selectionChanged()
        }
    }
}

// MARK: - View extension for haptics
extension View {
    func hapticOnTap(_ type: HapticService.FeedbackType = .impact(.medium)) -> some View {
        self.onTapGesture {
            Task { @MainActor in
                HapticService.shared.play(type)
            }
        }
    }
}
