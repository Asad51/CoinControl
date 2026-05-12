//
//  TransactionAddEditViewModelTests.swift
//  CoinControlTests
//

@testable import CoinControl
import Combine
import CoreData
import XCTest

final class TransactionAddEditViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var transactionService: TransactionService!
    var viewModel: TransactionAddEditViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        let persistence = PersistenceController(inMemory: true)
        context = persistence.viewContext
        transactionService = TransactionService(context: context)
        let categoryService = CategoryService(context: context)
        let accountService = AccountService(context: context)
        cancellables = []

        // Seed some transactions with titles
        let titles = ["Coffee", "Grocery", "Gas", "Lunch"]
        for title in titles {
            let t = Transaction(context: context)
            t.id = UUID()
            t.title = title
            t.amount = 10.0
            t.date = Date()
            t.type = TransactionType.expense.rawValue
        }
        try context.save()

        viewModel = TransactionAddEditViewModel(
            transactionService: transactionService,
            categoryService: categoryService,
            accountService: accountService
        )
    }

    func testSuggestionsFilter() {
        // When
        viewModel.title = "Co"

        // Then
        XCTAssertEqual(viewModel.suggestions.count, 1)
        XCTAssertTrue(viewModel.suggestions.contains("Coffee"))
    }

    func testSuggestionsEmptyOnNoMatch() {
        // When
        viewModel.title = "Xyz"

        // Then
        XCTAssertTrue(viewModel.suggestions.isEmpty, "Suggestions should be empty for 'Xyz', but got \(viewModel.suggestions)")
    }

    func testSuggestionsEmptyOnEmptyInput() {
        // When
        viewModel.title = ""

        // Then
        XCTAssertTrue(viewModel.suggestions.isEmpty, "Suggestions should be empty for empty input, but got \(viewModel.suggestions)")
    }

    func testSuggestionsExcludesExactMatch() {
        // When
        viewModel.title = "Coffee"

        // Then
        XCTAssertFalse(viewModel.suggestions.contains("Coffee"), "Suggestions should not include the exact current title 'Coffee'")
    }

    func testSuggestionsLimitToFive() throws {
        // Given
        // Seed 10 matching titles
        for i in 1 ... 10 {
            let t = Transaction(context: context)
            t.id = UUID()
            t.title = "Coffee \(i)"
            t.amount = Double(i)
            t.date = Date()
            t.type = TransactionType.expense.rawValue
        }
        try context.save()

        // Re-init view model to fetch new titles
        viewModel = TransactionAddEditViewModel(
            transactionService: transactionService,
            categoryService: CategoryService(context: context),
            accountService: AccountService(context: context)
        )

        // When
        viewModel.title = "Co"

        // Then
        XCTAssertEqual(viewModel.suggestions.count, 5, "Suggestions should be limited to 5, but got \(viewModel.suggestions.count)")
    }
}
