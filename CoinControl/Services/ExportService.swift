//
//  ExportService.swift
//  CoinControl
//

import Foundation
import Objects2XLSX

protocol ExportServiceProtocol {
    func exportTransactions(_ transactions: [TransactionExportItem]) async throws -> URL
}

class ExportService: ExportServiceProtocol {
    func exportTransactions(_ transactions: [TransactionExportItem]) async throws -> URL {
        // ... (styles)
        let headerStyle = CellStyle(
            font: Font(bold: true, color: .white),
            fill: Fill.solid(Color(hex: "#2C3E50")),
            alignment: Alignment(horizontal: .center),
            border: Border.all(style: .thin, color: .black)
        )

        let dateStyle = CellStyle.default
        let amountStyle = CellStyle.default

        let sheet = Sheet<TransactionExportItem>(name: "Transactions", dataProvider: { transactions }) {
            Column(name: "Date", keyPath: \.date)
                .width(15)
                .headerStyle(headerStyle)
                .bodyStyle(dateStyle)

            Column(name: "Title", keyPath: \.title)
                .width(25)
                .headerStyle(headerStyle)

            Column(name: "Type", keyPath: \.type)
                .width(12)
                .headerStyle(headerStyle)

            Column(name: "Category", keyPath: \.category)
                .width(20)
                .headerStyle(headerStyle)

            Column(name: "Account", keyPath: \.account)
                .width(20)
                .headerStyle(headerStyle)

            Column(name: "Currency", keyPath: \TransactionExportItem.currency)
                .width(10)
                .headerStyle(headerStyle)

            Column(name: "Amount", keyPath: \.amount)
                .width(15)
                .headerStyle(headerStyle)
                .bodyStyle(amountStyle)

            Column(name: "Note", keyPath: \.note)
                .width(30)
                .headerStyle(headerStyle)
        }

        let bookStyle = BookStyle()
        let book = Book(style: bookStyle, sheets: [AnySheet(sheet)])

        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "CoinControl_Export_\(DateFormatter.fileTimestamp.string(from: Date())).xlsx"
        let fileURL = tempDir.appendingPathComponent(fileName)

        try await book.writeAsync(to: fileURL)
        return fileURL
    }
}

extension DateFormatter {
    static let fileTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HHmmss"
        return formatter
    }()
}
