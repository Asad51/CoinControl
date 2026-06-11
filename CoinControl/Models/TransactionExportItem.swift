//
//  TransactionExportItem.swift
//  CoinControl
//

import Foundation

struct TransactionExportItem {
    let date: Date
    let title: String
    let type: String
    let category: String
    let account: String
    let currency: String
    let amount: Double
    let note: String
}
