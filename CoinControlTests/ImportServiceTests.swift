//
//  ImportServiceTests.swift
//  CoinControlTests
//

@testable import CoinControl
import CoreData
import XCTest

final class ImportServiceTests: XCTestCase {
    var context: NSManagedObjectContext!
    var transactionService: TransactionService!
    var categoryService: CategoryService!
    var accountService: AccountService!
    var importService: ImportService!

    override func setUpWithError() throws {
        let persistence = PersistenceController(inMemory: true)
        context = persistence.viewContext
        transactionService = TransactionService(context: context)
        categoryService = CategoryService(context: context)
        accountService = AccountService(context: context)
        importService = ImportService(
            context: context,
            transactionService: transactionService,
            categoryService: categoryService,
            accountService: accountService
        )
    }

    // MARK: - CSV Parsing Tests

    func testParseCSVBasicRow() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,Food,Wallet,5.50,Morning coffee
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].title, "Coffee")
        XCTAssertEqual(items[0].amount, 5.50, accuracy: 0.001)
        XCTAssertEqual(items[0].type, .expense)
        XCTAssertEqual(items[0].categoryName, "Food")
        XCTAssertEqual(items[0].accountName, "Wallet")
        XCTAssertEqual(items[0].note, "Morning coffee")
    }

    func testParseCSVQuotedFieldsWithCommas() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,"Coffee, Latte",Expense,Food,Wallet,5.50,"Good morning, indeed"
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].title, "Coffee, Latte")
        XCTAssertEqual(items[0].note, "Good morning, indeed")
    }

    func testParseCSVIncomeType() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Salary,Income,Work,Bank,3000.00,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].type, .income)
    }

    func testParseCSVMultipleDateFormats() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Item1,Expense,Food,Wallet,1.0,
        01/15/2024,Item2,Expense,Food,Wallet,2.0,
        15-01-2024,Item3,Expense,Food,Wallet,3.0,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 3, "All 3 rows with different date formats should parse successfully")
    }

    func testParseCSVSkipsInvalidRows() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        NOT_A_DATE,Coffee,Expense,Food,Wallet,5.50,
        2024-01-15,Coffee,Expense,Food,Wallet,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1, "Row with invalid date should be skipped")
    }

    func testParseCSVMissingRequiredHeadersThrows() throws {
        let csvContent = """
        Date,Title,Type,Account,Amount,Note
        2024-01-15,Coffee,Expense,Wallet,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        XCTAssertThrowsError(try importService.parseTransactions(from: fileURL)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "ImportService")
            XCTAssertEqual(nsError.code, 3)
        }
    }

    func testParseCSVEmptyFileThrows() throws {
        let csvContent = ""
        let fileURL = try writeTempCSV(content: csvContent)
        XCTAssertThrowsError(try importService.parseTransactions(from: fileURL)) { error in
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, "ImportService")
            XCTAssertEqual(nsError.code, 2)
        }
    }

    // MARK: - Duplicate Detection Tests

    func testDuplicateDetection() throws {
        // Seed an existing transaction into Core Data
        let account = Account(context: context)
        account.id = UUID()
        account.name = "Wallet"
        account.accountType = AccountType.cash.rawValue

        let existingTx = Transaction(context: context)
        existingTx.id = UUID()
        existingTx.title = "Coffee"
        existingTx.amount = 5.50
        existingTx.type = TransactionType.expense.rawValue
        existingTx.date = makeDate(year: 2024, month: 1, day: 15)
        existingTx.note = ""
        existingTx.account = account
        try context.save()

        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,Food,Wallet,5.50,Morning coffee
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertTrue(items[0].isDuplicate, "Transaction matching existing by date+title+amount should be marked as duplicate")
        XCTAssertFalse(items[0].isSelected, "Duplicates should default to unselected")
    }

    func testNonDuplicateDetection() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,New Transaction,Expense,Food,Wallet,15.00,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertFalse(items[0].isDuplicate, "Transaction with no existing match should not be duplicate")
        XCTAssertTrue(items[0].isSelected, "Non-duplicate should default to selected")
    }

    // MARK: - New Category / Account Detection Tests

    func testNewCategoryAndAccountDetected() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,BrandNewCategory,BrandNewAccount,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertTrue(items[0].isNewCategory, "Category not in DB should be flagged as new")
        XCTAssertTrue(items[0].isNewAccount, "Account not in DB should be flagged as new")
    }

    func testExistingCategoryAndAccountNotFlagged() throws {
        // Seed category and account
        try accountService.addAccount(name: "Wallet", type: .cash)
        try categoryService.addCategory(name: "Food", icon: "🍔", type: TransactionType.expense.rawValue)

        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,Food,Wallet,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        let items = try importService.parseTransactions(from: fileURL)
        XCTAssertEqual(items.count, 1)
        XCTAssertFalse(items[0].isNewCategory, "Existing category should not be flagged as new")
        XCTAssertFalse(items[0].isNewAccount, "Existing account should not be flagged as new")
    }

    // MARK: - Import Tests

    func testImportCreatesNewCategoryAndAccount() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,NewFood,NewWallet,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        var items = try importService.parseTransactions(from: fileURL)
        items[0].isSelected = true

        try importService.importTransactions(items)

        let accounts = try accountService.fetchAccounts()
        let categories = try categoryService.fetchCategories()
        let request = Transaction.fetchRequest()
        let transactions = try context.fetch(request)

        XCTAssertEqual(accounts.count, 1, "NewWallet account should be created")
        XCTAssertEqual(accounts[0].name, "NewWallet")
        XCTAssertEqual(categories.count, 1, "NewFood category should be created")
        XCTAssertEqual(categories[0].name, "NewFood")
        XCTAssertEqual(transactions.count, 1, "One transaction should be imported")
        XCTAssertEqual(transactions[0].title, "Coffee")
        XCTAssertEqual(transactions[0].amount, 5.50, accuracy: 0.001)
    }

    func testImportSkipsDeselectedItems() throws {
        let csvContent = """
        Date,Title,Type,Category,Account,Amount,Note
        2024-01-15,Coffee,Expense,Food,Wallet,5.50,
        """
        let fileURL = try writeTempCSV(content: csvContent)
        var items = try importService.parseTransactions(from: fileURL)
        items[0].isSelected = false

        try importService.importTransactions(items)

        let request = Transaction.fetchRequest()
        let transactions = try context.fetch(request)
        XCTAssertEqual(transactions.count, 0, "Deselected items should not be imported")
    }

    // MARK: - Helpers

    private func writeTempCSV(content: String) throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + ".csv")
        try content.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components)!
    }
}
