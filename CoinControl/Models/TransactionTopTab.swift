//
//  TransactionTopTab.swift
//  CoinControl
//

import Foundation

enum TransactionTopTab: String, CaseIterable {
    case daily = "Daily"
    case calendar = "Calendar"
    case monthly = "Monthly"
    case total = "Total"

    var title: String {
        self.rawValue
    }
}
