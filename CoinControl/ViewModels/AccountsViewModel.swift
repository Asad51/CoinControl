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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TransactionEntity")
        fetchRequest.resultType = .dictionaryResultType

        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumAmount"
        sumExpressionDesc.expression = NSExpression(forFunction: "sum:", arguments: [NSExpression(forKeyPath: "amount")])
        sumExpressionDesc.expressionResultType = .doubleAttributeType

        fetchRequest.propertiesToFetch = ["account", "type", sumExpressionDesc]
        fetchRequest.propertiesToGroupBy = ["account", "type"]

        do {
            guard let results = try context.fetch(fetchRequest) as? [[String: Any]] else { return }
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
            balances = newBalances
        } catch {
            print("Failed to calculate balances: \(error)")
        }
    }
}
