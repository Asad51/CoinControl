//
//  ExportPeriod.swift
//  CoinControl
//

import Foundation

enum ExportPeriod: String, CaseIterable, Identifiable {
    case monthly = "This Month"
    case lastMonth = "Last Month"
    case yearly = "This Year"
    case lastYear = "Last Year"
    case all = "All Time"

    var id: String {
        rawValue
    }

    func dateRange(from date: Date = Date()) -> (start: Date, end: Date)? {
        let calendar = Calendar.current
        switch self {
            case .monthly:
                guard let range = calendar.range(of: .day, in: .month, for: date),
                      let start = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) else { return nil }
                let end = calendar.date(byAdding: .day, value: range.count - 1, to: start)!
                return (calendar.startOfDay(for: start), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!)

            case .lastMonth:
                guard let lastMonthDate = calendar.date(byAdding: .month, value: -1, to: date),
                      let range = calendar.range(of: .day, in: .month, for: lastMonthDate),
                      let start = calendar.date(from: calendar.dateComponents([.year, .month], from: lastMonthDate)) else { return nil }
                let end = calendar.date(byAdding: .day, value: range.count - 1, to: start)!
                return (calendar.startOfDay(for: start), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!)

            case .yearly:
                let year = calendar.component(.year, from: date)
                guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
                      let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else { return nil }
                return (calendar.startOfDay(for: start), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!)

            case .lastYear:
                let year = calendar.component(.year, from: date) - 1
                guard let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
                      let end = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) else { return nil }
                return (calendar.startOfDay(for: start), calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!)

            case .all:
                return nil
        }
    }
}
