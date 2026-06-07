//
//  CurrencyFormatter.swift
//  CoinControl
//

import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "৳"
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static func format(_ amount: Double) -> String {
        formatter.string(from: NSNumber(value: amount)) ?? "৳\(String(format: "%.2f", amount))"
    }
}
