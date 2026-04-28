import Foundation

extension Date {
    var relativeFormatted: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date.now)
    }

    var shortFormatted: String {
        formatted(date: .abbreviated, time: .omitted)
    }

    var mediumFormatted: String {
        formatted(date: .long, time: .omitted)
    }

    var timeFormatted: String {
        formatted(date: .omitted, time: .shortened)
    }

    var dateTimeFormatted: String {
        formatted(date: .abbreviated, time: .shortened)
    }

    var dayMonthFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var monthYearFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: self)
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }

    var smartFormatted: String {
        if isToday { return "Today, \(timeFormatted)" }
        if isYesterday { return "Yesterday, \(timeFormatted)" }
        return dateTimeFormatted
    }

    func countdown(to end: Date) -> (hours: Int, minutes: Int, seconds: Int) {
        let diff = max(0, Int(end.timeIntervalSince(self)))
        let hours = diff / 3600
        let minutes = (diff % 3600) / 60
        let seconds = diff % 60
        return (hours, minutes, seconds)
    }
}
