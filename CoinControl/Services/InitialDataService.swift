//
//  InitialDataService.swift
//  CoinControl
//

import CoreData
import Foundation

class InitialDataService {
    private let context: NSManagedObjectContext
    private let userDefaults: UserDefaults
    private let key = "hasInsertedInitialData"

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext, userDefaults: UserDefaults = .standard) {
        self.context = context
        self.userDefaults = userDefaults
    }

    func checkAndInsertInitialData() {
        guard !userDefaults.bool(forKey: key) else { return }

        insertCategories()
        insertAccounts()

        do {
            try context.save()
            userDefaults.set(true, forKey: key)
            print("Initial data inserted successfully.")
        } catch {
            print("Failed to save initial data: \(error)")
        }
    }

    private func insertCategories() {
        let expenseCategories = [
            ("Food", "🍜"),
            ("Social Life", "👥"),
            ("Pets", "🐶"),
            ("Transport", "🚕"),
            ("Culture", "🖼️"),
            ("Household", "🪑"),
            ("Apparel", "👕"),
            ("Beauty", "💄"),
            ("Health", "🧘"),
            ("Entertainment", "🎮"),
            ("Education", "📙"),
            ("Gift", "🎁"),
            ("Others", "✨"),
        ]

        for (name, icon) in expenseCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.type = TransactionType.expense.rawValue
            category.desc = ""
        }

        let incomeCategories = [
            ("Allowance", "💵"),
            ("Salary", "💰"),
            ("Petty cash", "👛"),
            ("Bonus", "🧧"),
            ("Others", "✨"),
        ]

        for (name, icon) in incomeCategories {
            let category = Category(context: context)
            category.id = UUID()
            category.name = name
            category.icon = icon
            category.type = TransactionType.income.rawValue
            category.desc = ""
        }
    }

    private func insertAccounts() {
        let accounts = ["Cash", "Bank", "Credit Card"]

        for name in accounts {
            let account = Account(context: context)
            account.id = UUID()
            account.name = name
        }
    }
}
