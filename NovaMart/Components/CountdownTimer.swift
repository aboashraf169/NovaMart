import SwiftUI

struct CountdownTimer: View {
    let endDate: Date
    @State private var timeRemaining: (hours: Int, minutes: Int, seconds: Int) = (0, 0, 0)

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            TimerUnit(value: timeRemaining.hours, label: "HRS")
            TimerSeparator()
            TimerUnit(value: timeRemaining.minutes, label: "MIN")
            TimerSeparator()
            TimerUnit(value: timeRemaining.seconds, label: "SEC")
        }
        .onAppear { updateTime() }
        .onReceive(timer) { _ in updateTime() }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Time remaining: \(timeRemaining.hours) hours, \(timeRemaining.minutes) minutes, \(timeRemaining.seconds) seconds")
    }

    private func updateTime() {
        timeRemaining = Date.now.countdown(to: endDate)
    }
}

struct TimerUnit: View {
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            Text(String(format: "%02d", value))
                .font(.system(size: 22, weight: .black, design: .monospaced))
                .foregroundStyle(.primary)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.secondary)
        }
        .frame(width: 44, height: 44)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

struct TimerSeparator: View {
    @State private var visible = true

    var body: some View {
        Text(":")
            .font(.system(size: 20, weight: .black, design: .monospaced))
            .foregroundStyle(.secondary)
            .opacity(visible ? 1 : 0.2)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    visible = false
                }
            }
    }
}
