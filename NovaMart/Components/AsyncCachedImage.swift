import SwiftUI

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
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .transition(.opacity.animation(.smooth))
            } else if hasFailed {
                errorView ?? AnyView(
                    Image(systemName: "photo.fill")
                        .foregroundStyle(.secondary)
                )
            } else {
                placeholder ?? AnyView(
                    ShimmerBox(width: .infinity, height: .infinity, cornerRadius: 0)
                )
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
        defer { isLoading = false }

        guard let imageURL = URL(string: urlString) else {
            hasFailed = true
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: imageURL)
            guard let loaded = UIImage(data: data) else {
                hasFailed = true
                return
            }
            await ImageCache.shared.store(loaded, for: urlString)
            withAnimation(.smooth) {
                image = loaded
            }
        } catch {
            hasFailed = true
        }
    }
}
