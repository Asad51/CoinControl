//
//  AccountService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol AccountServiceProtocol {
    func fetchAccounts() throws -> [Account]
}

class AccountService: AccountServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchAccounts() throws -> [Account] {
        let request = Account.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Account.name, ascending: true)]
        return try context.fetch(request)
    }
}
