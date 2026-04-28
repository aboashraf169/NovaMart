import SwiftUI

struct RatingStarsView: View {
    let rating: Double
    let maxRating: Int
    var size: CGFloat = 12
    var color: Color = Color(hex: "#FFD700")
    var showValue: Bool = false

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { star in
                Image(systemName: iconName(for: star))
                    .font(.system(size: size, weight: .semibold))
                    .foregroundStyle(Double(star) <= rating ? color : Color(UIColor.systemGray4))
            }

            if showValue {
                Text(String(format: "%.1f", rating))
                    .font(.system(size: size - 1, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(String(format: "%.1f", rating)) out of \(maxRating) stars")
    }

    private func iconName(for star: Int) -> String {
        let diff = rating - Double(star - 1)
        if diff >= 1.0 { return "star.fill" }
        if diff >= 0.5 { return "star.leadinghalf.filled" }
        return "star"
    }
}

extension RatingStarsView {
    init(rating: Double, size: CGFloat = 12) {
        self.rating = rating
        self.maxRating = 5
        self.size = size
    }
}
