//
//  TransactionType.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//

import Foundation

enum TransactionType: Int16, CaseIterable, Identifiable {
    case income = 0
    case expense = 1
    case transfer = 2

    var id: Int16 {
        rawValue
    }

    var title: String {
        switch self {
            case .income: return "Income"
            case .expense: return "Expense"
            case .transfer: return "Transfer"
        }
    }
}
