//
//  CurrencyFormatter.swift
//  CoinControl
//

import Foundation

enum CurrencyFormatter {
    private static let lock = NSLock()
    private static var formatters: [String: NumberFormatter] = [:]

    static func format(_ amount: Double, currencySymbol: String = "৳") -> String {
        lock.lock()
        defer { lock.unlock() }

        let formatter = cachedFormatter(for: currencySymbol)
        return formatter.string(from: NSNumber(value: amount)) ?? "\(currencySymbol)\(String(format: "%.2f", amount))"
    }

    /// Returns a formatter for the given symbol, creating and caching it on first use.
    /// The lock must be held by the caller.
    private static func cachedFormatter(for currencySymbol: String) -> NumberFormatter {
        if let cached = formatters[currencySymbol] {
            return cached
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        formatter.usesGroupingSeparator = true
        formatter.currencySymbol = currencySymbol

        // Force the symbol to the front; the pattern still uses the locale's separators.
        formatter.positiveFormat = "¤#,##0.00"
        formatter.negativeFormat = "-¤#,##0.00"

        formatters[currencySymbol] = formatter
        return formatter
    }
}
