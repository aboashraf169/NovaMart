import SwiftUI

struct ImageCarouselView: View {
    let images: [ProductImage]
    @Binding var selectedIndex: Int
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        ZStack {
            if images.isEmpty {
                Rectangle()
                    .fill(Color(UIColor.systemGray6))
                    .overlay(
                        Image(systemName: "photo.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)
                    )
            } else {
                TabView(selection: $selectedIndex) {
                    ForEach(Array(images.enumerated()), id: \.element.id) { index, image in
                        AsyncCachedImage(url: image.url)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let delta = value / lastScale
                                        lastScale = value
                                        scale = min(max(scale * delta, 1.0), 4.0)
                                    }
                                    .onEnded { _ in
                                        lastScale = 1.0
                                        if scale < 1.05 {
                                            withAnimation(.smooth) {
                                                scale = 1.0
                                                offset = .zero
                                            }
                                        }
                                    }
                                    .simultaneously(with:
                                        DragGesture()
                                            .onChanged { value in
                                                if scale > 1.0 {
                                                    offset = value.translation
                                                }
                                            }
                                            .onEnded { _ in
                                                if scale <= 1.05 {
                                                    withAnimation(.smooth) {
                                                        offset = .zero
                                                    }
                                                }
                                            }
                                    )
                            )
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Custom dot indicators
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        ForEach(0..<images.count, id: \.self) { i in
                            Circle()
                                .fill(i == selectedIndex ? .white : .white.opacity(0.4))
                                .frame(width: i == selectedIndex ? 8 : 5, height: i == selectedIndex ? 8 : 5)
                                .animation(.bouncy, value: selectedIndex)
                        }
                    }
                    .padding(.bottom, AppSpacing.md)
                }
            }
        }
        .onTapGesture(count: 2) {
            withAnimation(.smooth) {
                if scale > 1.0 {
                    scale = 1.0
                    offset = .zero
                } else {
                    scale = 2.0
                }
            }
        }
        .onChange(of: selectedIndex) { _, _ in
            withAnimation(.smooth) {
                scale = 1.0
                offset = .zero
            }
        }
    }
}
