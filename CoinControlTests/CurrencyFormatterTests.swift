import XCTest
@testable import CoinControl

final class CurrencyFormatterTests: XCTestCase {
    func testPositiveCurrencyFormatting() {
        let amount = 1234.56
        let symbol = "$"
        let formatted = CurrencyFormatter.format(amount, currencySymbol: symbol)
        
        XCTAssertTrue(formatted.hasPrefix(symbol), "Positive amount should start with symbol: \(formatted)")
    }

    func testNegativeCurrencyFormatting() {
        let amount = -1234.56
        let symbol = "$"
        let formatted = CurrencyFormatter.format(amount, currencySymbol: symbol)
        
        // The fix uses "-¤#,##0.00" so it should be -$1,234.56
        XCTAssertTrue(formatted.hasPrefix("-\(symbol)"), "Negative amount should start with -\(symbol): \(formatted)")
    }

    func testForcedPrefixWithLocaleSeparators() {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "$"
        formatter.locale = Locale(identifier: "fr_FR")
        
        // Force prefix
        formatter.positiveFormat = "¤#,##0.00"
        
        let formatted = formatter.string(from: 1234.56 as NSNumber)!
        // fr_FR uses non-breaking space for grouping and comma for decimal
        XCTAssertTrue(formatted.hasPrefix("$"), "Should have $ prefix: \(formatted)")
        XCTAssertTrue(formatted.contains(",56"), "Should use comma for decimal: \(formatted)")
    }
}
