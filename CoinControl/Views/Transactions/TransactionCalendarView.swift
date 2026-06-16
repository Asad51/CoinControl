//
//  TransactionCalendarView.swift
//  CoinControl
//

import SwiftUI

struct TransactionCalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject var viewModel: TransactionsViewModel

    @State private var selectedDateForSheet: IdentifiableDate?
    @State private var selectedTransactionToEdit: Transaction?

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
                        .environmentObject(viewModel.settings)
                        .border(Color.secondary.opacity(0.1), width: 0.5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedDateForSheet = IdentifiableDate(date: date)
                        }
                    }
                }
            }
        }
        .sheet(item: $selectedDateForSheet) { identifiableDate in
            let date = identifiableDate.date
            let transactions = transactions(for: date)

            NavigationView {
                VStack {
                    if transactions.isEmpty {
                        EmptyStateView(
                            systemImage: "tray",
                            title: "No transactions",
                            message: "No transactions recorded for this day."
                        )
                    } else {
                        ScrollView {
                            DailySectionView(date: date, items: transactions) { transaction in
                                selectedTransactionToEdit = transaction
                            }
                        }
                    }
                }
                .navigationTitle(formatDate(date))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Close") {
                            selectedDateForSheet = nil
                        }
                    }
                }
                .sheet(item: $selectedTransactionToEdit) { transaction in
                    TransactionAddEditView(transactionToEdit: transaction)
                        .environment(\.managedObjectContext, viewContext)
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
        let transactions = transactions(for: date)
        return transactions
            .filter { $0.type == type.rawValue }
            .reduce(0) { $0 + $1.amount }
    }

    private func transactions(for date: Date) -> [Transaction] {
        viewModel.groupedTransactions.first(where: { calendar.isDate($0.0, inSameDayAs: date) })?.1 ?? []
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

struct IdentifiableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct CalendarCellView: View {
    @EnvironmentObject private var settings: Settings
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
                Text(CurrencyFormatter.format(income, currencySymbol: settings.currencySymbol))
                    .font(.system(size: 9))
                    .foregroundColor(.blue)
                    .lineLimit(1)
            }

            if expense > 0 {
                Text(CurrencyFormatter.format(expense, currencySymbol: settings.currencySymbol))
                    .font(.system(size: 9))
                    .foregroundColor(.red)
                    .lineLimit(1)
            }

            if income > 0 || expense > 0 {
                let total = income - expense
                Text(CurrencyFormatter.format(total, currencySymbol: settings.currencySymbol))
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
        TransactionCalendarView(viewModel: TransactionsViewModel(settings: Settings()))
    }
#endif
