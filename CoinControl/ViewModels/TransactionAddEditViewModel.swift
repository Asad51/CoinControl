//
//  TransactionAddEditViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class TransactionAddEditViewModel: ObservableObject {
    @Published var transactionType: TransactionType = .expense
    @Published var date = Date()
    @Published var amountText: String = ""
    @Published var title: String = ""
    @Published var note: String = ""
    @Published var selectedCategory: Category?
    @Published var selectedAccount: Account?

    @Published var categories: [Category] = []
    @Published var accounts: [Account] = []

    private let transactionService: TransactionServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let accountService: AccountServiceProtocol
    private let transactionToEdit: Transaction?

    var isEditing: Bool {
        transactionToEdit != nil
    }

    init(
        transactionToEdit: Transaction? = nil,
        transactionService: TransactionServiceProtocol = TransactionService(),
        categoryService: CategoryServiceProtocol = CategoryService(),
        accountService: AccountServiceProtocol = AccountService()
    ) {
        self.transactionToEdit = transactionToEdit
        self.transactionService = transactionService
        self.categoryService = categoryService
        self.accountService = accountService

        if let transaction = transactionToEdit {
            transactionType = TransactionType(rawValue: transaction.type) ?? .expense
            date = transaction.date
            amountText = String(format: "%.2f", transaction.amount)
            title = title
            note = transaction.note
            selectedCategory = transaction.category
            selectedAccount = transaction.account
        }

        fetchDependencies()
    }

    private func fetchDependencies() {
        do {
            categories = try categoryService.fetchCategories()
            accounts = try accountService.fetchAccounts()

            // Set defaults if not editing
            if !isEditing {
                if selectedAccount == nil {
                    selectedAccount = accounts.first
                }
                if selectedCategory == nil {
                    selectedCategory = categories.last
                }
            }
        } catch {
            print("Failed to fetch dependencies: \(error)")
        }
    }

    func save() -> Bool {
        guard let amount = Double(amountText) else {
            return false
        }

        do {
            try transactionService.saveTransaction(
                id: transactionToEdit?.id,
                type: transactionType.rawValue,
                amount: amount,
                date: date,
                title: title,
                note: note,
                category: selectedCategory ?? categories.last,
                account: selectedAccount ?? accounts.first
            )
            return true
        } catch {
            print("Failed to save transaction: \(error)")
            return false
        }
    }
}
