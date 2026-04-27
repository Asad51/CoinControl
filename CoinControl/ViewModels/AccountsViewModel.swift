//
//  AccountsViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

@MainActor
class AccountsViewModel: ObservableObject {
    @Published var accounts: [Account] = []
    @Published var balances: [UUID: Double] = [:]

    private let context: NSManagedObjectContext
    private let accountService: AccountServiceProtocol

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext,
         accountService: AccountServiceProtocol? = nil)
    {
        self.context = context
        self.accountService = accountService ?? AccountService(context: context)
        fetchAccounts()
    }

    func fetchAccounts() {
        do {
            accounts = try accountService.fetchAccounts()
            calculateBalances()
        } catch {
            print("Failed to fetch accounts: \(error)")
        }
    }

    private func calculateBalances() {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        do {
            let transactions = try context.fetch(request)
            var newBalances: [UUID: Double] = [:]
            for transaction in transactions {
                guard let account = transaction.account else { continue }
                let amount = transaction.type == TransactionType.expense.rawValue ? -transaction.amount : transaction.amount
                newBalances[account.id, default: 0.0] += amount
            }
            balances = newBalances
        } catch {
            print("Failed to fetch transactions for balances: \(error)")
        }
    }
}
