//
//  AccountType.swift
//  CoinControl
//

import Foundation

enum AccountType: Int16, CaseIterable, Identifiable {
    case cash = 0
    case bank = 1
    case card = 2

    var id: Int16 {
        rawValue
    }

    var title: String {
        switch self {
            case .cash: return "Cash"
            case .bank: return "Bank"
            case .card: return "Card"
        }
    }
}
