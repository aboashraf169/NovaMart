import SwiftUI

struct ReturnRequestView: View {
    let order: Order
    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason = ""
    @State private var additionalNotes = ""
    @State private var submitted = false

    let reasons = [
        "Item damaged on arrival",
        "Wrong item received",
        "Item doesn't match description",
        "Changed my mind",
        "Size/fit issue",
        "Quality not as expected",
        "Other"
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    if submitted {
                        VStack(spacing: AppSpacing.lg) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 64))
                                .foregroundStyle(AppTheme.Colors.success)
                                .symbolEffect(.pulse)

                            Text("Return Requested")
                                .font(AppTheme.Typography.title2)

                            Text("We've received your return request for **\(order.orderNumber)**. You'll receive a prepaid label by email within 24 hours.")
                                .font(AppTheme.Typography.bodyMedium)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)

                            GlassButton("Done") { dismiss() }
                        }
                        .padding(AppSpacing.screenPadding)
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            Text("Why are you returning this item?")
                                .font(AppTheme.Typography.labelLarge)

                            ForEach(reasons, id: \.self) { reason in
                                Button {
                                    selectedReason = reason
                                    HapticService.shared.play(.selection)
                                } label: {
                                    HStack {
                                        Text(reason).font(AppTheme.Typography.bodySmall).foregroundStyle(.primary)
                                        Spacer()
                                        Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(selectedReason == reason ? AppTheme.Colors.primary : .secondary)
                                    }
                                    .padding(AppSpacing.cardPadding)
                                    .glassCard(tint: selectedReason == reason ? AppTheme.Colors.primary : nil)
                                }
                                .buttonStyle(ScalePressEffect())
                            }

                            Text("Additional Notes (optional)")
                                .font(AppTheme.Typography.labelMedium)

                            TextField("Describe the issue...", text: $additionalNotes, axis: .vertical)
                                .lineLimit(4...8)
                                .padding(AppSpacing.md)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))

                            GlassButton("Submit Return Request") {
                                guard !selectedReason.isEmpty else { return }
                                withAnimation(.smooth) { submitted = true }
                                HapticService.shared.play(.notification(.success))
                            }
                            .disabled(selectedReason.isEmpty)
                            .opacity(selectedReason.isEmpty ? 0.5 : 1)
                        }
                        .padding(AppSpacing.screenPadding)
                    }
                }
            }
            .background(AnimatedMeshBackground())
            .navigationTitle("Return Request")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
