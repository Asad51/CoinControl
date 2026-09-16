//
//  ImportService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol ImportServiceProtocol {
    func parseTransactions(from fileURL: URL) throws -> [ParsedTransactionItem]
    func importTransactions(_ items: [ParsedTransactionItem]) throws
}

struct ParsedTransactionItem: Identifiable, Hashable {
    let id = UUID()
    var date: Date
    var title: String
    var type: TransactionType
    var categoryName: String
    var accountName: String
    var amount: Double
    var note: String
    
    // Validation states
    var isSelected: Bool = true
    var isDuplicate: Bool = false
    var isNewCategory: Bool = false
    var isNewAccount: Bool = false
}

class ImportService: ImportServiceProtocol {
    private let context: NSManagedObjectContext
    private let transactionService: TransactionServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let accountService: AccountServiceProtocol

    init(
        context: NSManagedObjectContext = PersistenceController.shared.viewContext,
        transactionService: TransactionServiceProtocol = TransactionService(),
        categoryService: CategoryServiceProtocol = CategoryService(),
        accountService: AccountServiceProtocol = AccountService()
    ) {
        self.context = context
        self.transactionService = transactionService
        self.categoryService = categoryService
        self.accountService = accountService
    }

    func parseTransactions(from fileURL: URL) throws -> [ParsedTransactionItem] {
        // Start accessing security scoped resource if necessary
        let didStartAccessing = fileURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccessing {
                fileURL.stopAccessingSecurityScopedResource()
            }
        }

        let data = try Data(contentsOf: fileURL)
        guard let contentString = String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii) else {
            throw NSError(domain: "ImportService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to read file contents as text"])
        }

        let parsedCSV = parseCSV(contents: contentString)
        guard !parsedCSV.isEmpty else {
            throw NSError(domain: "ImportService", code: 2, userInfo: [NSLocalizedDescriptionKey: "The CSV file is empty"])
        }

        let headers = parsedCSV[0].map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() }
        
        // Find indices of columns
        guard let dateIndex = headers.firstIndex(of: "date"),
              let titleIndex = headers.firstIndex(of: "title"),
              let typeIndex = headers.firstIndex(of: "type"),
              let categoryIndex = headers.firstIndex(of: "category"),
              let accountIndex = headers.firstIndex(of: "account"),
              let amountIndex = headers.firstIndex(of: "amount") else {
            throw NSError(domain: "ImportService", code: 3, userInfo: [NSLocalizedDescriptionKey: "Required headers are missing (Date, Title, Type, Category, Account, Amount)"])
        }
        
        let noteIndex = headers.firstIndex(of: "note")

        // Fetch existing database entities for validation and deduplication
        let existingTransactions = try fetchAllTransactions()
        let existingCategories = try categoryService.fetchCategories()
        let existingAccounts = try accountService.fetchAccounts()

        var parsedItems: [ParsedTransactionItem] = []

        // Parse remaining lines
        for rowIndex in 1..<parsedCSV.count {
            let row = parsedCSV[rowIndex]
            // Skip empty rows or header length mismatches
            if row.isEmpty || row.allSatisfy({ $0.isEmpty }) { continue }
            if row.count <= max(dateIndex, max(titleIndex, max(typeIndex, max(categoryIndex, max(accountIndex, amountIndex))))) {
                continue
            }

            guard let date = parseDate(row[dateIndex]) else { continue }
            let title = row[titleIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let type = parseType(row[typeIndex])
            let categoryName = row[categoryIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            let accountName = row[accountIndex].trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Clean up currency symbols or commas in amount
            let cleanedAmountStr = row[amountIndex]
                .replacingOccurrences(of: ",", with: "")
                .trimmingCharacters(in: CharacterSet.decimalDigits.inverted.subtracting(CharacterSet(charactersIn: ".")))
            guard let amount = Double(cleanedAmountStr) else { continue }
            
            let note = noteIndex != nil && noteIndex! < row.count ? row[noteIndex!].trimmingCharacters(in: .whitespacesAndNewlines) : ""

            // Determine check flags
            let isNewCategory = !existingCategories.contains { $0.name.localizedCaseInsensitiveCompare(categoryName) == .orderedSame && $0.type == type }
            let isNewAccount = !existingAccounts.contains { $0.name.localizedCaseInsensitiveCompare(accountName) == .orderedSame }
            
            // Duplicate check: Same Date (day precision), Title, and Amount
            let isDuplicate = existingTransactions.contains { existingTx in
                let calendar = Calendar.current
                let sameDay = calendar.isDate(existingTx.date, inSameDayAs: date)
                let sameAmount = abs(existingTx.amount - amount) < 0.01
                let sameTitle = (existingTx.title ?? "").localizedCaseInsensitiveCompare(title) == .orderedSame
                
                return sameDay && sameAmount && sameTitle
            }

            var item = ParsedTransactionItem(
                date: date,
                title: title,
                type: type,
                categoryName: categoryName,
                accountName: accountName,
                amount: amount,
                note: note
            )
            item.isNewCategory = isNewCategory
            item.isNewAccount = isNewAccount
            item.isDuplicate = isDuplicate
            
            // Default select to false for duplicates, and true for others
            item.isSelected = !isDuplicate

            parsedItems.append(item)
        }

        return parsedItems
    }

    func importTransactions(_ items: [ParsedTransactionItem]) throws {
        var existingCategories = try categoryService.fetchCategories()
        var existingAccounts = try accountService.fetchAccounts()

        for item in items {
            guard item.isSelected else { continue }

            // 1. Resolve or create category
            var category = existingCategories.first {
                $0.name.localizedCaseInsensitiveCompare(item.categoryName) == .orderedSame && $0.type == item.type
            }
            if category == nil {
                try categoryService.addCategory(name: item.categoryName, icon: "✨", type: item.type.rawValue)
                existingCategories = try categoryService.fetchCategories()
                category = existingCategories.first {
                    $0.name.localizedCaseInsensitiveCompare(item.categoryName) == .orderedSame && $0.type == item.type
                }
            }

            // 2. Resolve or create account
            var account = existingAccounts.first {
                $0.name.localizedCaseInsensitiveCompare(item.accountName) == .orderedSame
            }
            if account == nil {
                try accountService.addAccount(name: item.accountName, type: .cash)
                existingAccounts = try accountService.fetchAccounts()
                account = existingAccounts.first {
                    $0.name.localizedCaseInsensitiveCompare(item.accountName) == .orderedSame
                }
            }

            // 3. Save transaction
            try transactionService.saveTransaction(
                id: nil,
                type: item.type.rawValue,
                amount: item.amount,
                date: item.date,
                title: item.title,
                note: item.note,
                category: category,
                account: account
            )
        }
    }

    // MARK: - Helper Methods

    private func fetchAllTransactions() throws -> [Transaction] {
        let request = Transaction.fetchRequest()
        return try context.fetch(request)
    }

    private func parseCSV(contents: String) -> [[String]] {
        var result: [[String]] = []
        var currentRecord: [String] = []
        var currentField = ""
        var inQuotes = false
        
        let chars = Array(contents)
        var i = 0
        while i < chars.count {
            let char = chars[i]
            
            if inQuotes {
                if char == "\"" {
                    if i + 1 < chars.count && chars[i + 1] == "\"" {
                        currentField.append("\"")
                        i += 1
                    } else {
                        inQuotes = false
                    }
                } else {
                    currentField.append(char)
                }
            } else {
                if char == "\"" {
                    inQuotes = true
                } else if char == "," {
                    currentRecord.append(currentField)
                    currentField = ""
                } else if char == "\n" {
                    currentRecord.append(currentField)
                    result.append(currentRecord)
                    currentRecord = []
                    currentField = ""
                } else if char == "\r" {
                    if i + 1 < chars.count && chars[i + 1] == "\n" {
                        // Do nothing, handled in next loop iteration
                    } else {
                        currentRecord.append(currentField)
                        result.append(currentRecord)
                        currentRecord = []
                        currentField = ""
                    }
                } else {
                    currentField.append(char)
                }
            }
            i += 1
        }
        
        if !currentField.isEmpty || !currentRecord.isEmpty {
            currentRecord.append(currentField)
            result.append(currentRecord)
        }
        
        return result
    }

    private func parseDate(_ dateString: String) -> Date? {
        let formats = [
            "yyyy-MM-dd HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ssZ",
            "yyyy-MM-dd'T'HH:mm:ss.SSSZ",
            "yyyy-MM-dd",
            "MM/dd/yyyy HH:mm:ss",
            "MM/dd/yyyy HH:mm",
            "MM/dd/yyyy",
            "M/d/yy H:mm",
            "M/d/yy h:mm a",
            "dd-MM-yyyy",
            "dd/MM/yyyy"
        ]
        
        let trimmed = dateString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        for format in formats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: trimmed) {
                return date
            }
        }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: trimmed) {
            return date
        }
        
        return nil
    }

    private func parseType(_ typeString: String) -> TransactionType {
        let lower = typeString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        if lower.contains("income") || lower == "1" {
            return .income
        } else {
            return .expense
        }
    }
}
