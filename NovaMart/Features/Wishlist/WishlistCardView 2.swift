//
//  WishlistCardView 2.swift
//  NovaMart
//
//  Created by mido mj on 5/14/26.
//


import SwiftUI

struct WishlistCardView: View {

    let item: WishlistItem
    @Bindable var viewModel: WishlistViewModel

    @Environment(AppState.self) private var appState

    private var product: Product { item.product }

    var body: some View {
            NavigationLink(destination: ProductDetailView(product: product)) {
                HStack(spacing: 8) {
                // Thumbnail
                AsyncCachedImage(url: product.primaryImage?.url)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: 100,maxHeight: 100)                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Spacer()
                // Details
                VStack(alignment: .leading, spacing: 3) {
                    // Brand + remove button
                    HStack(alignment: .top) {
                        Text(product.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        // Remove from wishlist — top right
                        Button {
                            withAnimation(.smooth) {
                                viewModel.remove(itemID: item.id, appState: appState)
                            }
                            HapticService.shared.play(.impact(.light))
                        } label: {
                            Image(systemName: "heart.slash")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(ScalePressEffect())
                    }
                    
                        Text(product.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    

                    HStack(spacing: 3) {
                        RatingStarsView(rating: product.rating, size: 10)
                        Text(String(format: "%.1f", product.rating))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                        Text("(\(product.reviewCount))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer(minLength: 4)

                    // Price + Add to Cart
                    HStack(alignment: .center, spacing: 5) {
                        Text("$\(product.price, format: .number.precision(.fractionLength(2)))")
                            .font(.callout)
                            .fontWeight(.bold)
                            .foregroundStyle(
                                product.compareAtPrice != nil
                                ? Color.red
                                : AppTheme.Colors.primary
                            )
                        if let compare = product.compareAtPrice {
                            Text("$\(compare, format: .number.precision(.fractionLength(2)))")
                                .font(.subheadline)
                                .foregroundStyle(.tertiary)
                                .strikethrough()
                        }
                    

                        Spacer()

                        // Add to Cart button — compact
                        Button {
                            viewModel.moveToCart(item: item, appState: appState)
                            HapticService.shared.play(.notification(.success))
                        } label: {
                            HStack(spacing: 5) {
                                Image(systemName: "bag.badge.plus")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(
                                product.isOutOfStock ? Color.secondary : AppTheme.Colors.primary,
                                in: Capsule()
                            )
                        }
                        .buttonStyle(ScalePressEffect())
                        .disabled(product.isOutOfStock)
                    }
                }
            }
        }
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                withAnimation {
                    viewModel.remove(itemID: item.id, appState: appState)
                }
            } label: {
                Label("Remove", systemImage: "heart.slash.fill")
            }
        }
        .swipeActions(edge: .leading, allowsFullSwipe: true) {
            Button {
                viewModel.moveToCart(item: item, appState: appState)
                HapticService.shared.play(.notification(.success))
            } label: {
                Label("Add to Cart", systemImage: "bag.badge.plus")
            }
            .tint(AppTheme.Colors.primary)
        }
    }
}

#Preview {
    @Previewable @State var vm = WishlistViewModel()
    let items = Product.samples.prefix(9).map { product in
        WishlistItem(
            id: UUID(), product: product, addedAt: .now,
            priceAlertEnabled: true,
            priceAtAdd: product.compareAtPrice ?? product.price
        )
    }
    List {
        ForEach(items) { item in
            WishlistCardView(item: item, viewModel: vm)
        }
    }
    .environment(AppState())
}
