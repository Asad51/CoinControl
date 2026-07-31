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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
        fetchRequest.resultType = .dictionaryResultType

        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumAmount"
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        sumExpressionDesc.expressionResultType = .doubleAttributeType

        fetchRequest.propertiesToFetch = ["account", "type", sumExpressionDesc]
        fetchRequest.propertiesToGroupBy = ["account", "type"]

        let results = try context.fetch(fetchRequest) as? [[String: Any]] ?? []
        var newBalances: [UUID: Double] = [:]
        for dict in results {
            guard let accountID = dict["account"] as? NSManagedObjectID,
                  let type = dict["type"] as? Int16,
                  let sumAmount = dict["sumAmount"] as? Double else { continue }

            if let account = try? context.existingObject(with: accountID) as? Account {
                let amount = type == TransactionType.expense.rawValue ? -sumAmount : sumAmount
                newBalances[account.id, default: 0.0] += amount
            }
        }
        return newBalances
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
        if let account = try context.fetch(request).first {
            context.delete(account)
            try context.save()
        }
    }
}
