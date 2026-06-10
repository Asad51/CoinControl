//
//  CurrencyFormatter.swift
//  CoinControl
//

import Foundation

enum CurrencyFormatter {
    private static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    static func format(_ amount: Double, currencySymbol: String = "৳") -> String {
        formatter.currencySymbol = currencySymbol

        // Force symbol to be at the beginning regardless of locale
        formatter.positiveFormat = "¤#,##0.00"
        formatter.negativeFormat = "-¤#,##0.00"

        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencySymbol)\(String(format: "%.2f", amount))"
    }
}
