import SwiftUI

struct GlassSearchBar: View {
    @Binding var text: String
    var placeholder: String = "Search products..."
    var onSubmit: (() -> Void)? = nil
    var onMicTap: (() -> Void)? = nil
    var isFocused: Bool = false
    @FocusState private var fieldFocused: Bool

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .font(AppTheme.Typography.bodyLarge)
                .focused($fieldFocused)
                .submitLabel(.search)
                .onSubmit { onSubmit?() }
                .accessibilityLabel("Search field")

            if !text.isEmpty {
                Button {
                    text = ""
                    HapticService.shared.play(.impact(.light))
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                .transition(.scale.combined(with: .opacity))
            } else if let onMicTap {
                Button(action: onMicTap) {
                    Image(systemName: "mic.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(AppTheme.Colors.primary)
                }
                .accessibilityLabel("Voice search")
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .frame(height: AppSpacing.inputHeight)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.Radius.button, style: .continuous)
                .strokeBorder(
                    fieldFocused ? AppTheme.Colors.primary.opacity(0.5) : Color.white.opacity(0.15),
                    lineWidth: fieldFocused ? 1.5 : 0.5
                )
        }
        .animation(.snappy, value: text.isEmpty)
        .animation(.snappy, value: fieldFocused)
        .onAppear {
            if isFocused {
                fieldFocused = true
            }
        }
    }
}
