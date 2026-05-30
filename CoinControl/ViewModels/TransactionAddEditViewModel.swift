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
    @Published var suggestions: [String] = []

    @Published var titleError: String?
    @Published var amountError: String?
    @Published var categoryError: String?

    private var allTitles: [String] = []
    private let transactionService: TransactionServiceProtocol
    private let categoryService: CategoryServiceProtocol
    private let accountService: AccountServiceProtocol
    private let transactionToEdit: Transaction?
    private var cancellables = Set<AnyCancellable>()

    var isEditing: Bool {
        transactionToEdit != nil
    }

    var isValid: Bool {
        title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false &&
            (Double(amountText) ?? 0) > 0 &&
            selectedCategory != nil
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
            title = transaction.title
            note = transaction.note
            selectedCategory = transaction.category
            selectedAccount = transaction.account
        }

        setupSubscribers()
        fetchDependencies()
    }

    private func setupSubscribers() {
        $transactionType
            .dropFirst()
            .sink { [weak self] newType in
                self?.filterCategories(for: newType)
            }
            .store(in: &cancellables)

        $title
            .sink { [weak self] newTitle in
                self?.filterSuggestions(for: newTitle)
            }
            .store(in: &cancellables)
    }

    private func filterSuggestions(for input: String) {
        if input.isEmpty {
            suggestions = []
            return
        }

        let filtered = allTitles.filter {
            $0.localizedCaseInsensitiveContains(input) && $0.lowercased() != input.lowercased()
        }

        var uniqueSuggestions = [String]()
        var seen = Set<String>()

        for suggestion in filtered {
            let lowercased = suggestion.lowercased()
            if !seen.contains(lowercased) {
                seen.insert(lowercased)
                uniqueSuggestions.append(suggestion)
            }
            if uniqueSuggestions.count >= 5 {
                break
            }
        }

        suggestions = uniqueSuggestions
    }

    private func filterCategories(for type: TransactionType) {
        do {
            categories = try categoryService.fetchCategories(by: type.rawValue)
            if !isEditing || selectedCategory?.type != type.rawValue {
                selectedCategory = categories.first
            }
        } catch {
            print("Failed to filter categories: \(error)")
        }
    }

    private func fetchDependencies() {
        do {
            categories = try categoryService.fetchCategories(by: transactionType.rawValue)
            accounts = try accountService.fetchAccounts()
            allTitles = try transactionService.fetchUniqueTitles()

            // Set defaults if not editing
            if !isEditing {
                if selectedAccount == nil {
                    selectedAccount = accounts.first
                }
                if selectedCategory == nil {
                    selectedCategory = categories.first
                }
            }
        } catch {
            print("Failed to fetch dependencies: \(error)")
        }
    }

    func save() -> Bool {
        guard validate() else {
            return false
        }

        guard let amount = Double(amountText) else {
            amountError = "Enter a valid amount"
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
                category: selectedCategory ?? categories.first,
                account: selectedAccount ?? accounts.first
            )
            return true
        } catch {
            print("Failed to save transaction: \(error)")
            return false
        }
    }

    @discardableResult
    func validate() -> Bool {
        var isValid = true

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            titleError = "Title is required"
            isValid = false
        } else {
            titleError = nil
        }

        if let amount = Double(amountText), amount > 0 {
            amountError = nil
        } else {
            amountError = "Enter a valid amount"
            isValid = false
        }

        if selectedCategory == nil {
            categoryError = "Category is required"
            isValid = false
        } else {
            categoryError = nil
        }

        return isValid
    }

    func delete() -> Bool {
        guard let transaction = transactionToEdit else { return false }
        do {
            try transactionService.deleteTransaction(transaction)
            return true
        } catch {
            print("Failed to delete transaction: \(error)")
            return false
        }
    }
}
