//
//  TransactionsViewModelTests.swift
//  CoinControlTests
//

@testable import CoinControl
import Combine
import CoreData
import XCTest

final class TransactionsViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var transactionService: TransactionService!
    var viewModel: TransactionsViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUpWithError() throws {
        let persistence = PersistenceController(inMemory: true)
        context = persistence.viewContext
        transactionService = TransactionService(context: context)
        cancellables = []

        // Seed some data
        let account = Account(context: context)
        account.id = UUID()
        account.name = "Bank Account"

        let category = Category(context: context)
        category.id = UUID()
        category.name = "Food"
        category.icon = "🍔"

        let t1 = Transaction(context: context)
        t1.id = UUID()
        t1.title = "Coffee"
        t1.note = "Starbucks"
        t1.amount = 5.50
        t1.date = Date()
        t1.type = TransactionType.expense.rawValue
        t1.account = account
        t1.category = category

        let t2 = Transaction(context: context)
        t2.id = UUID()
        t2.title = "Salary"
        t2.note = "Monthly payment"
        t2.amount = 5000.00
        t2.date = Date()
        t2.type = TransactionType.income.rawValue

        try context.save()

        viewModel = TransactionsViewModel(transactionService: transactionService)
    }

    func testSearchByTitle() {
        let expectation = XCTestExpectation(description: "Search finishes")

        viewModel.$filteredTransactions
            .dropFirst() // Drop initial empty state
            .sink { transactions in
                if !transactions.isEmpty {
                    XCTAssertEqual(transactions.count, 1)
                    XCTAssertEqual(transactions.first?.title, "Coffee")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchQuery = "Coffee"

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchByNote() {
        let expectation = XCTestExpectation(description: "Search finishes")

        viewModel.$filteredTransactions
            .dropFirst()
            .sink { transactions in
                if !transactions.isEmpty {
                    XCTAssertEqual(transactions.count, 1)
                    XCTAssertEqual(transactions.first?.note, "Starbucks")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchQuery = "Starbucks"

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchByCategory() {
        let expectation = XCTestExpectation(description: "Search finishes")

        viewModel.$filteredTransactions
            .dropFirst()
            .sink { transactions in
                if !transactions.isEmpty {
                    XCTAssertEqual(transactions.count, 1)
                    XCTAssertEqual(transactions.first?.category?.name, "Food")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchQuery = "Food"

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchByAccount() {
        let expectation = XCTestExpectation(description: "Search finishes")

        viewModel.$filteredTransactions
            .dropFirst()
            .sink { transactions in
                if !transactions.isEmpty {
                    XCTAssertEqual(transactions.count, 1)
                    XCTAssertEqual(transactions.first?.account?.name, "Bank Account")
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchQuery = "Bank"

        wait(for: [expectation], timeout: 2.0)
    }

    func testSearchByAmount() {
        let expectation = XCTestExpectation(description: "Search finishes")

        viewModel.$filteredTransactions
            .dropFirst()
            .sink { transactions in
                if !transactions.isEmpty {
                    XCTAssertEqual(transactions.count, 1)
                    XCTAssertEqual(transactions.first?.amount, 5.50)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.searchQuery = "5.50"

        wait(for: [expectation], timeout: 2.0)
    }
}
