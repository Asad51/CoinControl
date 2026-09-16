//
//  AccountsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

@MainActor
class AccountsViewModel: ObservableObject {
    @Published var accounts: [AccountModel] = []
    @Published var balances: [UUID: Double] = [:]
    @Published var errorMessage: String? = nil

    private let accountService: AccountServiceProtocol

    init(accountService: AccountServiceProtocol = AccountService()) {
        self.accountService = accountService
        fetchAccounts()
    }

    func fetchAccounts() {
        do {
            accounts = try accountService.fetchAccounts()
            balances = try accountService.getBalances()
        } catch {
            print("Failed to fetch accounts or balances: \(error)")
        }
    }

    func addAccount(name: String, type: AccountType) {
        do {
            try accountService.addAccount(name: name, type: type)
            fetchAccounts()
        } catch {
            print("Failed to add account: \(error)")
        }
    }

    func updateAccount(id: UUID, name: String, type: AccountType) {
        do {
            try accountService.updateAccount(id: id, name: name, type: type)
            fetchAccounts()
        } catch {
            print("Failed to update account: \(error)")
        }
    }

    @discardableResult
    func deleteAccount(_ account: AccountModel) -> Bool {
        do {
            try accountService.deleteAccount(account)
            fetchAccounts()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
