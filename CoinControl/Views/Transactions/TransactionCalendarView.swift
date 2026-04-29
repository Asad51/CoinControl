//
//  TransactionCalendarView.swift
//  CoinControl
//

import SwiftUI

struct TransactionCalendarView: View {
    @ObservedObject var viewModel: TransactionsViewModel

    private let calendar = Calendar.current
    private let daysInWeek = 7
    private let weekDays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(spacing: 0) {
            // Weekday Headers
            HStack(spacing: 0) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(day == "Sun" ? .red : (day == "Sat" ? .blue : .secondary))
                        .padding(.vertical, 8)
                }
            }
            .background(Color(UIColor.secondarySystemBackground).opacity(0.5))

            GeometryReader { geometry in
                let cellWidth = geometry.size.width / CGFloat(daysInWeek)
                let cellHeight = geometry.size.height / 6 // Assume max 6 weeks
                let days = generateDays()

                LazyVGrid(columns: Array(repeating: GridItem(.fixed(cellWidth), spacing: 0), count: daysInWeek), spacing: 0) {
                    ForEach(0 ..< days.count, id: \.self) { index in
                        let date = days[index]
                        CalendarCellView(
                            date: date,
                            isCurrentMonth: calendar.isDate(date, equalTo: viewModel.selectedDate, toGranularity: .month),
                            isToday: calendar.isDateInToday(date),
                            income: dailyTotal(for: date, type: .income),
                            expense: dailyTotal(for: date, type: .expense),
                            width: cellWidth,
                            height: cellHeight
                        )
                        .border(Color.secondary.opacity(0.1), width: 0.5)
                    }
                }
            }
        }
    }

    private func generateDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: viewModel.selectedDate) else { return [] }
        let firstDayOfMonth = monthInterval.start

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offset = firstWeekday - 1

        guard let startDate = calendar.date(byAdding: .day, value: -offset, to: firstDayOfMonth) else { return [] }

        var days: [Date] = []
        for i in 0 ..< 42 { // 6 weeks * 7 days
            if let day = calendar.date(byAdding: .day, value: i, to: startDate) {
                days.append(day)
            }
        }
        return days
    }

    private func dailyTotal(for date: Date, type: TransactionType) -> Double {
        let transactions = viewModel.groupedTransactions.first(where: { calendar.isDate($0.0, inSameDayAs: date) })?.1 ?? []
        return transactions
            .filter { $0.type == type.rawValue }
            .reduce(0) { $0 + $1.amount }
    }
}

struct CalendarCellView: View {
    let date: Date
    let isCurrentMonth: Bool
    let isToday: Bool
    let income: Double
    let expense: Double
    let width: CGFloat
    let height: CGFloat

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            HStack {
                if isToday {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(UIColor.systemBackground))
                        .padding(4)
                        .background(Color.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 12))
                        .foregroundColor(isCurrentMonth ? .primary : .secondary.opacity(0.5))
                        .padding(4)
                }
                Spacer()
            }

            Spacer()

            if income > 0 {
                Text(String(format: "%.0f", income))
                    .font(.system(size: 9))
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }

            if expense > 0 {
                Text(String(format: "%.0f", expense))
                    .font(.system(size: 9))
                    .foregroundColor(.red)
                    .lineLimit(1)
            }

            if income > 0 || expense > 0 {
                let total = income - expense
                Text(String(format: "%.0f", total))
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
        }
        .padding(2)
        .frame(width: width, height: height, alignment: .topTrailing)
        .background(isCurrentMonth ? Color(UIColor.systemBackground) : Color(UIColor.secondarySystemBackground).opacity(0.3))
    }
}

#if DEBUG
    #Preview {
        TransactionCalendarView(viewModel: TransactionsViewModel())
    }
#endif
