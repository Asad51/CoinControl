//
//  TransactionMonthlyView.swift
//  CoinControl
//

import SwiftUI

struct TransactionMonthlyView: View {
    @ObservedObject var viewModel: TransactionsViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(viewModel.yearlyTransactions, id: \.0) { monthDate, transactions in
                    MonthRowView(viewModel: viewModel, monthDate: monthDate, transactions: transactions)
                }
            }
        }
    }
}

struct MonthRowView: View {
    @ObservedObject var viewModel: TransactionsViewModel
    let monthDate: Date
    let transactions: [Transaction]

    @State private var isExpanded: Bool = false
    private let calendar = Calendar.current

    init(viewModel: TransactionsViewModel, monthDate: Date, transactions: [Transaction]) {
        self.viewModel = viewModel
        self.monthDate = monthDate
        self.transactions = transactions
        // Initial state: expand if it matches selectedDate's month
        _isExpanded = State(initialValue: Calendar.current.isDate(monthDate, equalTo: viewModel.selectedDate, toGranularity: .month))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Month Header Row
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(monthName)
                            .font(.headline)
                            .foregroundColor(.primary)

                        Text(monthRangeString)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 12) {
                        VStack(alignment: .trailing, spacing: 2) {
                            if monthIncome > 0 {
                                Text("৳ \(String(format: "%.2f", monthIncome))")
                                    .foregroundColor(.blue)
                            }

                            if monthExpense > 0 {
                                Text("৳ \(String(format: "%.2f", monthExpense))")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .font(.system(.subheadline, design: .monospaced))

                    Spacer()

                    Text("৳ \(String(format: "%.2f", monthIncome - monthExpense))")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
            }
            .buttonStyle(PlainButtonStyle())

            Divider()

            if isExpanded {
                let weeks = groupTransactionsByWeek(transactions)
                ForEach(weeks, id: \.0) { weekDate, weekTransactions in
                    WeekRowView(weekDate: weekDate, transactions: weekTransactions)
                }
            }
        }
        .onChange(of: viewModel.selectedDate) { newDate in
            // Auto-expand/collapse based on external month selection
            isExpanded = calendar.isDate(monthDate, equalTo: newDate, toGranularity: .month)
        }
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter.string(from: monthDate)
    }

    private var monthRangeString: String {
        guard let range = calendar.range(of: .day, in: .month, for: monthDate),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: monthDate)),
              let lastDay = calendar.date(byAdding: .day, value: range.count - 1, to: firstDay)
        else {
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "M.d"
        return "\(formatter.string(from: firstDay)) ~ \(formatter.string(from: lastDay))"
    }

    private var monthIncome: Double {
        transactions.filter { $0.type == TransactionType.income.rawValue }.reduce(0) { $0 + $1.amount }
    }

    private var monthExpense: Double {
        transactions.filter { $0.type == TransactionType.expense.rawValue }.reduce(0) { $0 + $1.amount }
    }

    private func groupTransactionsByWeek(_ txs: [Transaction]) -> [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: txs) { tx in
            calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: tx.date))!
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

struct WeekRowView: View {
    let weekDate: Date
    let transactions: [Transaction]
    private let calendar = Calendar.current

    var body: some View {
        let isCurrentWeek = calendar.isDate(Date(), equalTo: weekDate, toGranularity: .weekOfYear)

        HStack {
            Text(weekRangeString)
                .font(.subheadline)
                .foregroundColor(.primary)

            Spacer()

            HStack(spacing: 12) {
                VStack(alignment: .trailing, spacing: 2) {
                    if weekIncome > 0 {
                        Text("৳ \(String(format: "%.2f", weekIncome))")
                            .foregroundColor(.blue)
                    }

                    if weekExpense > 0 {
                        Text("৳ \(String(format: "%.2f", weekExpense))")
                            .foregroundColor(.red)
                    }
                }
            }
            .font(.system(.subheadline, design: .monospaced))

            Spacer()

            Text("৳ \(String(format: "%.2f", weekIncome - weekExpense))")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(isCurrentWeek ? Color.red.opacity(0.1) : Color(UIColor.secondarySystemBackground).opacity(0.3))

        Divider()
    }

    private var weekRangeString: String {
        let startOfWeek = weekDate
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd"
        return "\(formatter.string(from: startOfWeek)) ~ \(formatter.string(from: endOfWeek))"
    }

    private var weekIncome: Double {
        transactions.filter { $0.type == TransactionType.income.rawValue }.reduce(0) { $0 + $1.amount }
    }

    private var weekExpense: Double {
        transactions.filter { $0.type == TransactionType.expense.rawValue }.reduce(0) { $0 + $1.amount }
    }
}
