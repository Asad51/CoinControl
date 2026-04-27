//
//  AccountsViewModelTests.swift
//  CoinControlTests
//

@testable import CoinControl
import CoreData
import XCTest

final class AccountsViewModelTests: XCTestCase {
    var context: NSManagedObjectContext!
    var viewModel: AccountsViewModel!

    @MainActor
    override func setUpWithError() throws {
        let persistence = PersistenceController(inMemory: true)
        context = persistence.viewContext
        viewModel = AccountsViewModel(context: context)
    }

    @MainActor
    func testCalculateBalances() throws {
        // Given
        let account = Account(context: context)
        let accountId = UUID()
        account.id = accountId
        account.name = "Test Account"

        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.amount = 100.0
        transaction1.type = TransactionType.income.rawValue
        transaction1.account = account
        transaction1.date = Date()

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = 40.0
        transaction2.type = TransactionType.expense.rawValue
        transaction2.account = account
        transaction2.date = Date()

        try context.save()

        // When
        viewModel.fetchAccounts()

        // Then
        XCTAssertEqual(viewModel.accounts.count, 1, "Should have 1 account")
        if !viewModel.accounts.isEmpty {
            XCTAssertEqual(viewModel.accounts[0].id, accountId, "Account ID should match")
            XCTAssertEqual(viewModel.balances[accountId], 60.0, "Balance should be 60.0 but was \(viewModel.balances[accountId] ?? -1.0)")
        }
    }
}
