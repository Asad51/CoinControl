//
//  AccountType.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 17/2/24.
//

import Foundation

enum AccountType {
    case cash
    case card
    case accounts

    var title: String {
        switch self {
            case .cash:
                return "Cash"
            case .card:
                return "Card"
            case .accounts:
                return "Accounts"
        }
    }
}
