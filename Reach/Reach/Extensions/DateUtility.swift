//
//  DateUtility.swift
//  CIG
//
//  Copyright © 2017 Aanchal Jain. All rights reserved.
//

import Foundation
struct DateUtility {

    static let dateSeprator = "-"

    // MARK: Date time calculation
    static func calculateTime12HourFormat(_ dateStr: String) -> String {
        // Convert string to date object
        var date: Date?
        let dateFormat = AppUtility.getDateFormat()
        date = dateFormat.date(from: dateStr)

        dateFormat.dateFormat = "h:mma"
        dateFormat.amSymbol = "am"
        dateFormat.pmSymbol = "pm"

        guard let selectedDate = date else { return ""}
        let strDate = dateFormat.string(from: selectedDate)
        return strDate

    }

    // MARK: Date time calculation
    static func calculateTime12HourFormatFromDate(_ date: Date) -> String {
        // Convert string to date object
        let dateFormat = AppUtility.getDateFormat()
        dateFormat.dateFormat = "h:mma"
        dateFormat.amSymbol = "am"
        dateFormat.pmSymbol = "pm"
        let strDate = dateFormat.string(from: date)
        return strDate

    }

    static func calculateDateWeekDayFormat(_ dateStr: String) -> String {
        // Convert string to date object
        var date: Date?
        let dateFormat = AppUtility.getDateFormat()
        date = dateFormat.date(from: dateStr)

        dateFormat.dateFormat = "EEEE, MMMM d"

        guard let selectedDate = date else { return ""}
        let strDate = dateFormat.string(from: selectedDate)
        return strDate

    }

    static func calculateDateWeekDayFormatWithYear(_ dateStr: String) -> String {
        // Convert string to date object
        var date: Date?
        let dateFormat = AppUtility.getDateFormat()
        date = dateFormat.date(from: dateStr)

        dateFormat.dateFormat = "EEEE, MMMM d yyyy"

        guard let selectedDate = date else { return ""}
        let strDate = dateFormat.string(from: selectedDate)
        return strDate

    }

    static func getDateStr(from date: Date) -> String {
        let dateFormat = AppUtility.getDateFormat()
        let strDate = dateFormat.string(from: date)
        return strDate
    }

    static func getDate(from str: String) -> Date? {
        let dateFormat = AppUtility.getDateFormat()
        let date = dateFormat.date(from: str)
        return date
    }

    static func interval(dateA: Date, dateB: Date) -> Int {

        let diffInDays = Calendar.current.dateComponents([.day], from: dateA, to: dateB).day
        return diffInDays ?? 0
    }

    static func intervalInHours(dateA: Date, dateB: Date) -> Int {

        let diffInHours = Calendar.current.dateComponents([.hour], from: dateA, to: dateB).hour
        return diffInHours ?? 0
    }

    static func intervalInHoursMinute(dateA: Date, dateB: Date) -> String {

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: dateA, to: dateB)
        if let hour = components.hour, let minute = components.minute, let second = components.second {

            return "\(hour)h : " + "\(minute)m : " + "\(second)s"
        }

        return ""
    }

    static func intervalInHoursMinuteDateFormat(dateA: Date, dateB: Date) -> Date? {

        let components = Calendar.current.dateComponents([.hour, .minute, .second], from: dateA, to: dateB)
        if let hour = components.hour, let minute = components.minute, let second = components.second {

            let date = Calendar.current.date(bySettingHour: hour, minute: minute, second: second, of: Date())
            return date
        }
        return nil
    }

    static func reduceOneSecondFromTime(date: Date?) -> String {

        guard let dateExists = date else { return "" }
        let reducedDate = Calendar.current.date(byAdding: .second,
                                                value: -1,
                                                to: dateExists)
        guard let reducedDateExists = reducedDate else { return ""}
        let dateStr = getDateStr(from: reducedDateExists)
        return dateStr

    }
}
