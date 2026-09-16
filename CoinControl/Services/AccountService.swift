//
//  AccountService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol AccountServiceProtocol {
    func fetchAccounts() throws -> [AccountModel]
    func getBalances() throws -> [UUID: Double]
    func addAccount(name: String, type: AccountType) throws
    func updateAccount(id: UUID, name: String, type: AccountType) throws
    func deleteAccount(_ accountModel: AccountModel) throws
}

class AccountService: AccountServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchAccounts() throws -> [AccountModel] {
        let request = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        let accounts = try context.fetch(request)
        return accounts.map { $0.toModel }
    }

    func getBalances() throws -> [UUID: Double] {
        // Grouping by the `account` relationship in a dictionary fetch is unreliable,
        // so aggregate in memory instead. Transactions without an account can't be
        // attributed to a balance and are intentionally skipped.
        let request = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "account != nil")
        let transactions = try context.fetch(request)

        var balances: [UUID: Double] = [:]
        for transaction in transactions {
            guard let account = transaction.account else { continue }
            let signedAmount = transaction.type == TransactionType.expense.rawValue
                ? -transaction.amount
                : transaction.amount
            balances[account.id, default: 0.0] += signedAmount
        }
        return balances
    }

    func addAccount(name: String, type: AccountType) throws {
        let account = Account(context: context)
        account.id = UUID()
        account.name = name
        account.accountType = type.rawValue
        try context.save()
    }

    func updateAccount(id: UUID, name: String, type: AccountType) throws {
        let request = Account.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let account = try context.fetch(request).first {
            account.name = name
            account.accountType = type.rawValue
            try context.save()
        } else {
            throw NSError(domain: "AccountService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Account not found"])
        }
    }

    func deleteAccount(_ accountModel: AccountModel) throws {
        let request = Account.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", accountModel.id as CVarArg)
        guard let account = try context.fetch(request).first else { return }

        // Deleting the account would orphan its transactions, so block it while referenced.
        let countRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
        countRequest.predicate = NSPredicate(format: "account == %@", account)
        let transactionCount = try context.count(for: countRequest)
        guard transactionCount == 0 else {
            let noun = transactionCount == 1 ? "transaction" : "transactions"
            throw NSError(
                domain: "AccountService",
                code: 409,
                userInfo: [NSLocalizedDescriptionKey: "“\(accountModel.name)” can’t be deleted because \(transactionCount) \(noun) still use it. Delete or reassign those transactions first."]
            )
        }

        context.delete(account)
        try context.save()
    }
}
