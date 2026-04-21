//
//  DailySectionViewModel.swift
//  CoinControl
//

import Foundation

struct DailySectionViewModel {
    let date: Date
    let items: [Transaction]

    var dailyExpense: Double {
        items.filter { $0.type == TransactionType.expense.rawValue }.reduce(0) { $0 + $1.amount }
    }

    var dailyIncome: Double {
        items.filter { $0.type == TransactionType.income.rawValue }.reduce(0) { $0 + $1.amount }
    }

    func formattedDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
