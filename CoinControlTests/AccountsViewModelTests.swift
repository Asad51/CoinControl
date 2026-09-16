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
        viewModel = AccountsViewModel(accountService: AccountService(context: context))
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
        transaction1.title = ""
        transaction1.note = ""

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.amount = 40.0
        transaction2.type = TransactionType.expense.rawValue
        transaction2.account = account
        transaction2.date = Date()
        transaction2.title = ""
        transaction2.note = ""

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

    @MainActor
    func testAddAccount() {
        // Given
        XCTAssertEqual(viewModel.accounts.count, 0)

        // When
        viewModel.addAccount(name: "New Savings", type: .bank)

        // Then
        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts[0].name, "New Savings")
        XCTAssertEqual(viewModel.accounts[0].type, .bank)
    }

    @MainActor
    func testUpdateAccount() {
        // Given
        viewModel.addAccount(name: "Original Name", type: .cash)
        let addedAccount = viewModel.accounts[0]

        // When
        viewModel.updateAccount(id: addedAccount.id, name: "Updated Name", type: .card)

        // Then
        XCTAssertEqual(viewModel.accounts.count, 1)
        XCTAssertEqual(viewModel.accounts[0].name, "Updated Name")
        XCTAssertEqual(viewModel.accounts[0].type, .card)
    }

    @MainActor
    func testDeleteAccount() {
        // Given
        viewModel.addAccount(name: "To Be Deleted", type: .card)
        let addedAccount = viewModel.accounts[0]
        XCTAssertEqual(viewModel.accounts.count, 1)

        // When
        viewModel.deleteAccount(addedAccount)

        // Then
        XCTAssertEqual(viewModel.accounts.count, 0)
    }

    @MainActor
    func testDeleteAccountWithTransactionsIsBlocked() throws {
        // Given
        viewModel.addAccount(name: "In Use", type: .cash)
        let addedAccount = viewModel.accounts[0]

        let accountRequest = Account.fetchRequest()
        accountRequest.predicate = NSPredicate(format: "id == %@", addedAccount.id as CVarArg)
        let managedAccount = try XCTUnwrap(context.fetch(accountRequest).first)

        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.amount = 10.0
        transaction.type = TransactionType.expense.rawValue
        transaction.date = Date()
        transaction.title = ""
        transaction.note = ""
        transaction.account = managedAccount
        try context.save()

        // When
        let deleted = viewModel.deleteAccount(addedAccount)

        // Then
        XCTAssertFalse(deleted, "Deletion should be refused while transactions reference the account")
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.accounts.count, 1, "Account should still exist")
    }
}
