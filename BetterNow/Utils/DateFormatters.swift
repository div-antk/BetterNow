//
//  DateFormatters.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//


//
//  DateFormatters.swift
//  BetterNow
//
//  Created by Takuya Ando on 2026/02/15.
//

import Foundation

/// Centralised date formatting utilities.
/// Keep formatting decisions out of Views so UI code stays clean.
enum DateFormatters {

    /// Example (ja): 2026年2月15日 日曜日
    /// Example (en): Sunday, February 15, 2026
    static func headerDate(_ date: Date = .now, locale: Locale = .autoupdatingCurrent) -> String {
        date.formatted(
            .dateTime
                .weekday(.wide)
                .year()
                .month()
                .day()
                .locale(locale)
        )
    }

    /// Short weekday variant for compact UI.
    /// Example (ja): 2026/02/15 (日)
    /// Example (en): 15/02/2026 (Sun)
    static func headerDateCompact(_ date: Date = .now, locale: Locale = .autoupdatingCurrent) -> String {
        let datePart = date.formatted(
            .dateTime
                .year()
                .month(.twoDigits)
                .day(.twoDigits)
                .locale(locale)
        )
        let weekdayPart = date.formatted(
            .dateTime
                .weekday(.abbreviated)
                .locale(locale)
        )
        return "\(datePart) (\(weekdayPart))"
    }

    /// ISO-like key for persistence (day-level). Example: 2026-02-15
    static func dayKey(_ date: Date = .now, timeZone: TimeZone = .autoupdatingCurrent) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = timeZone

        let comps = cal.dateComponents([.year, .month, .day], from: date)
        guard let y = comps.year, let m = comps.month, let d = comps.day else { return "" }

        // zero-pad
        let mm = String(format: "%02d", m)
        let dd = String(format: "%02d", d)
        return "\(y)-\(mm)-\(dd)"
    }
}
