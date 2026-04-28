import SwiftUI

enum AppTheme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color(hex: "#6E3AFF")
        static let secondary = Color(hex: "#00D4AA")
        static let accent = Color(hex: "#FF6B35")
        static let success = Color(hex: "#34C759")
        static let warning = Color(hex: "#FF9F0A")
        static let error = Color(hex: "#FF3B30")

        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let textTertiary = Color(UIColor.tertiaryLabel)

        static let cardBackground = Color(UIColor.secondarySystemBackground)
        static let surfaceBackground = Color(UIColor.systemBackground)

        // Gradients
        static let backgroundGradientDark: [Color] = [
            Color(hex: "#0D0A1A"),
            Color(hex: "#1A0A2E"),
            Color(hex: "#0A1628"),
            Color(hex: "#0D1A1A")
        ]
        static let backgroundGradientLight: [Color] = [
            Color(hex: "#F8F4FF"),
            Color(hex: "#F0F8FF"),
            Color(hex: "#F4FFFC"),
            Color(hex: "#FFF8F4")
        ]

        static let primaryGradient = LinearGradient(
            colors: [Color(hex: "#6E3AFF"), Color(hex: "#9B59FF")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let accentGradient = LinearGradient(
            colors: [Color(hex: "#FF6B35"), Color(hex: "#FF9B35")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        static let goldGradient = LinearGradient(
            colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Typography
    enum Typography {
        // Display
        static let display = Font.system(.largeTitle, design: .default, weight: .bold)
        static let displayLight = Font.system(.largeTitle, design: .default, weight: .light)

        // Titles
        static let title1 = Font.system(.title, design: .default, weight: .bold)
        static let title2 = Font.system(.title2, design: .default, weight: .semibold)
        static let title3 = Font.system(.title3, design: .default, weight: .semibold)

        // Body
        static let bodyLarge = Font.system(.body, design: .default, weight: .regular)
        static let bodyMedium = Font.system(.callout, design: .default, weight: .regular)
        static let bodySmall = Font.system(.subheadline, design: .default, weight: .regular)

        // Labels
        static let labelLarge = Font.system(.headline, design: .default, weight: .semibold)
        static let labelMedium = Font.system(.subheadline, design: .default, weight: .medium)
        static let labelSmall = Font.system(.footnote, design: .default, weight: .medium)

        // Caption
        static let caption = Font.system(.caption, design: .default, weight: .regular)
        static let captionBold = Font.system(.caption, design: .default, weight: .semibold)

        // Price — monospaced for alignment
        static let priceLarge = Font.system(.title2, design: .monospaced, weight: .bold)
        static let priceMedium = Font.system(.body, design: .monospaced, weight: .semibold)
        static let priceSmall = Font.system(.callout, design: .monospaced, weight: .medium)
    }

    // MARK: - Corner Radius
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let card: CGFloat = 20
        static let button: CGFloat = 16
        static let sheet: CGFloat = 28
        static let pill: CGFloat = 100
    }

    // MARK: - Shadows
    enum Shadow {
        static let card = (color: Color.black.opacity(0.12), radius: CGFloat(16), x: CGFloat(0), y: CGFloat(8))
        static let elevated = (color: Color.black.opacity(0.2), radius: CGFloat(24), x: CGFloat(0), y: CGFloat(12))
    }

    // MARK: - Mesh Gradient Points
    static func meshPoints(phase: Double) -> [SIMD2<Float>] {
        let shift = Float(sin(phase) * 0.05)
        return [
            SIMD2<Float>(0, 0),
            SIMD2<Float>(0.5 + shift, 0),
            SIMD2<Float>(1, 0),
            SIMD2<Float>(0, 0.5 - shift),
            SIMD2<Float>(0.5, 0.5),
            SIMD2<Float>(1, 0.5 + shift),
            SIMD2<Float>(0, 1),
            SIMD2<Float>(0.5 - shift, 1),
            SIMD2<Float>(1, 1)
        ]
    }

    static func meshColors(isDark: Bool, phase: Double) -> [Color] {
        if isDark {
            return [
                Color(hex: "#0D0A1A"),
                Color(hex: "#15082A"),
                Color(hex: "#0A0F22"),
                Color(hex: "#1A0A2E"),
                Color(hex: "#160E2A"),
                Color(hex: "#0A1628"),
                Color(hex: "#0A1420"),
                Color(hex: "#0D1A1A"),
                Color(hex: "#0A0D15")
            ]
        } else {
            return [
                Color(hex: "#F8F4FF"),
                Color(hex: "#F3EEFF"),
                Color(hex: "#EEF6FF"),
                Color(hex: "#F5EEFF"),
                Color(hex: "#F2F2FF"),
                Color(hex: "#EEF8FF"),
                Color(hex: "#F4FFFC"),
                Color(hex: "#F2FFF9"),
                Color(hex: "#FFF8F4")
            ]
        }
    }
}

// MARK: - Loyalty Tier
enum LoyaltyTier: String, Codable, Sendable {
    case bronze, silver, gold, platinum

    var color: Color {
        switch self {
        case .bronze: Color(hex: "#CD7F32")
        case .silver: Color(hex: "#C0C0C0")
        case .gold: Color(hex: "#FFD700")
        case .platinum: Color(hex: "#E5E4E2")
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .bronze:
            return LinearGradient(colors: [Color(hex: "#CD7F32"), Color(hex: "#A0522D")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .silver:
            return LinearGradient(colors: [Color(hex: "#C0C0C0"), Color(hex: "#808080")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .gold:
            return LinearGradient(colors: [Color(hex: "#FFD700"), Color(hex: "#FFA500")], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .platinum:
            return LinearGradient(colors: [Color(hex: "#E5E4E2"), Color(hex: "#A0A0A0")], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var pointsRequired: Int {
        switch self {
        case .bronze: 0
        case .silver: 500
        case .gold: 2000
        case .platinum: 10000
        }
    }

    var nextTier: LoyaltyTier? {
        switch self {
        case .bronze: .silver
        case .silver: .gold
        case .gold: .platinum
        case .platinum: nil
        }
    }
}
