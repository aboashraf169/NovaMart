import SwiftUI

// Animated shimmer gradient that fills any frame without needing explicit dimensions
private struct ShimmerGradient: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: 0),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: max(0, phase - 0.3)),
                .init(color: Color(UIColor.systemGray4).opacity(0.95), location: phase),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: min(1, phase + 0.3)),
                .init(color: Color(UIColor.systemGray5).opacity(0.6), location: 1)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

struct AsyncCachedImage: View {
    let url: String?
    let contentMode: ContentMode
    let placeholder: AnyView?
    let errorView: AnyView?

    @State private var image: UIImage? = nil
    @State private var isLoading = false
    @State private var hasFailed = false

    init(
        url: String?,
        contentMode: ContentMode = .fill,
        @ViewBuilder placeholder: () -> some View = { ShimmerBox(width: .infinity, height: .infinity, cornerRadius: 0) },
        @ViewBuilder errorView: () -> some View = { Image(systemName: "photo.fill").foregroundStyle(.secondary) }
    ) {
        self.url = url
        self.contentMode = contentMode
        self.placeholder = AnyView(placeholder())
        self.errorView = AnyView(errorView())
    }

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else if hasFailed {
                errorView ?? AnyView(
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.secondary)
                )
            }

            // Shimmer overlay while loading — fades out when image arrives
            if isLoading || (image == nil && !hasFailed) {
                ShimmerGradient()
                    .transition(.opacity.animation(.smooth))
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private func loadImage() async {
        guard let urlString = url, !urlString.isEmpty else {
            hasFailed = true
            return
        }

        // Check cache first
        if let cached = await ImageCache.shared.image(for: urlString) {
            image = cached
            return
        }

        isLoading = true

        guard let imageURL = URL(string: urlString) else {
            hasFailed = true
            isLoading = false
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            guard let loaded = UIImage(data: data) else {
                hasFailed = true
                isLoading = false
                return
            }
            await ImageCache.shared.store(loaded, for: urlString)
            withAnimation(.smooth) {
                image = loaded
                isLoading = false
            }
        } catch {
            hasFailed = true
            isLoading = false
        }
    }
}
