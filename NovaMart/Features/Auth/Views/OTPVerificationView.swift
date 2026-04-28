import SwiftUI

struct OTPVerificationView: View {
    let destination: String
    let onVerified: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var digits: [String] = Array(repeating: "", count: 6)
    @State private var focusedIndex = 0
    @State private var isVerifying = false
    @State private var errorMessage: String?
    @State private var resendCooldown = 30
    @State private var canResend = false
    @FocusState private var focusedField: Int?

    private var fullCode: String { digits.joined() }
    private var isComplete: Bool { fullCode.count == 6 }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: AppSpacing.xl) {
                    VStack(spacing: AppSpacing.md) {
                        Image(systemName: "envelope.badge.shield.half.filled.fill")
                            .font(.system(size: 56))
                            .foregroundStyle(AppTheme.Colors.primaryGradient)
                            .symbolEffect(.pulse)

                        Text("Verify Your Identity")
                            .font(AppTheme.Typography.title2)

                        Text("Enter the 6-digit code sent to **\(destination)**")
                            .font(AppTheme.Typography.bodyMedium)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, AppSpacing.xl)

                    OTPFieldRow(digits: $digits, focusedField: $focusedField, focusedIndex: $focusedIndex)

                    if let error = errorMessage {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundStyle(AppTheme.Colors.error)
                            Text(error)
                                .font(AppTheme.Typography.bodySmall)
                                .foregroundStyle(AppTheme.Colors.error)
                        }
                        .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                    }

                    GlassButton("Verify Code") {
                        verify()
                    }
                    .disabled(!isComplete || isVerifying)
                    .opacity(!isComplete || isVerifying ? 0.5 : 1)

                    if isVerifying {
                        ProgressView()
                            .tint(AppTheme.Colors.primary)
                    }

                    HStack(spacing: AppSpacing.xs) {
                        Text("Didn't receive a code?")
                            .font(AppTheme.Typography.bodySmall)
                            .foregroundStyle(.secondary)

                        Button {
                            resendCode()
                        } label: {
                            if canResend {
                                Text("Resend")
                                    .font(AppTheme.Typography.labelSmall)
                                    .foregroundStyle(AppTheme.Colors.primary)
                            } else {
                                Text("Resend in \(resendCooldown)s")
                                    .font(AppTheme.Typography.labelSmall)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .disabled(!canResend)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
            .background(AnimatedMeshBackground())
            .navigationTitle("Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { dismiss() }
                }
            }
        }
        .onAppear {
            focusedField = 0
            startResendTimer()
        }
    }

    private func verify() {
        guard isComplete else { return }
        withAnimation(.smooth) { errorMessage = nil }
        isVerifying = true
        HapticService.shared.play(.impact(.medium))

        Task {
            try? await Task.sleep(for: .seconds(1.2))
            await MainActor.run {
                isVerifying = false
                // Demo: any code works
                if fullCode == "000000" {
                    withAnimation(.smooth) {
                        errorMessage = "Invalid code. Please try again."
                    }
                    HapticService.shared.play(.notification(.error))
                    digits = Array(repeating: "", count: 6)
                    focusedField = 0
                } else {
                    HapticService.shared.play(.notification(.success))
                    onVerified()
                }
            }
        }
    }

    private func resendCode() {
        canResend = false
        resendCooldown = 30
        HapticService.shared.play(.selection)
        startResendTimer()
    }

    private func startResendTimer() {
        Task {
            while resendCooldown > 0 {
                try? await Task.sleep(for: .seconds(1))
                await MainActor.run { resendCooldown -= 1 }
            }
            await MainActor.run { canResend = true }
        }
    }
}

private struct OTPFieldRow: View {
    @Binding var digits: [String]
    var focusedField: FocusState<Int?>.Binding
    @Binding var focusedIndex: Int

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            ForEach(0..<6, id: \.self) { index in
                OTPDigitField(
                    digit: Binding(
                        get: { digits[index] },
                        set: { newVal in
                            let filtered = newVal.filter(\.isNumber)
                            if filtered.count > 1 {
                                let chars = Array(filtered)
                                for i in index..<min(index + chars.count, 6) {
                                    digits[i] = String(chars[i - index])
                                }
                                let next = min(index + chars.count, 5)
                                focusedField.wrappedValue = next
                            } else {
                                digits[index] = String(filtered.prefix(1))
                                if !filtered.isEmpty, index < 5 {
                                    focusedField.wrappedValue = index + 1
                                }
                            }
                        }
                    ),
                    isFocused: focusedField.wrappedValue == index,
                    onDelete: {
                        if digits[index].isEmpty, index > 0 {
                            digits[index - 1] = ""
                            focusedField.wrappedValue = index - 1
                        } else {
                            digits[index] = ""
                        }
                    }
                )
                .focused(focusedField, equals: index)
            }
        }
    }
}

private struct OTPDigitField: View {
    @Binding var digit: String
    let isFocused: Bool
    let onDelete: () -> Void

    var body: some View {
        TextField("", text: $digit)
            .font(.system(size: 24, weight: .bold, design: .monospaced))
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .frame(width: 46, height: 54)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.Radius.medium, style: .continuous)
                    .strokeBorder(
                        isFocused ? AppTheme.Colors.primary : Color(UIColor.separator),
                        lineWidth: isFocused ? 2 : 1
                    )
            }
            .animation(.snappy, value: isFocused)
    }
}
