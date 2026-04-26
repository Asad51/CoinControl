//
//  PreviewData.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 15/2/24.
//

import CoreData
import Foundation

struct PreviewData {
    var transaction: (NSManagedObjectContext) -> Transaction {{ context in
        let category = Category(context: context)
        category.id = UUID()
        category.name = "Groceries"
        category.icon = "cart"
        category.desc = "groceries"

        let account = Account(context: context)
        account.id = UUID()
        account.name = "Cash"

        let transaction = Transaction(context: context)
        transaction.id = UUID()
        transaction.title = "Chicken"
        transaction.date = Date().addingTimeInterval(-100_000)
        transaction.category = category
        transaction.account = account
        transaction.amount = 10.61
        transaction.type = TransactionType.expense.rawValue
        transaction.note = "Bought 6kgs of chicken."

        return transaction
    }}

    var transactions: (NSManagedObjectContext) -> [Transaction] {{ context in
        // Create Mock Categories for the grid
        let categoriesData: [(String, String)] = [
            ("Food", "🍜"),
            ("Social Life", "👥"),
            ("Pets", "🐶"),
            ("Transport", "🚕"),
            ("Culture", "🖼️"),
            ("Household", "🪑"),
            ("Apparel", "👕"),
            ("Beauty", "💄"),
            ("Health", "🧘"),
            ("Education", "📙"),
            ("Gift", "🎁"),
            ("Other", "•"),
        ]

        var categories: [Category] = []
        for (name, icon) in categoriesData {
            let cat = Category(context: context)
            cat.id = UUID()
            cat.name = name
            cat.icon = icon
            cat.desc = "Description"
            categories.append(cat)
        }

        // Create Mock Accounts
        let accountNames = ["Cash", "Card", "Bank"]
        var accounts: [Account] = []
        for name in accountNames {
            let acct = Account(context: context)
            acct.id = UUID()
            acct.name = name
            accounts.append(acct)
        }

        let transaction1 = Transaction(context: context)
        transaction1.id = UUID()
        transaction1.title = "Tea"
        transaction1.date = Date().addingTimeInterval(-100_000)
        transaction1.category = categories.first { $0.name == "Household" } ?? categories.last!
        transaction1.account = accounts.first { $0.name == "Cash" } ?? accounts.first!
        transaction1.amount = 12.0
        transaction1.type = 0
        transaction1.note = "Consumed tea with Mr. Maruf."

        let transaction2 = Transaction(context: context)
        transaction2.id = UUID()
        transaction2.title = "Salary"
        transaction2.date = Date().addingTimeInterval(-1_000_000)
        transaction2.category = categories.first { $0.name == "Other" } ?? categories.last!
        transaction2.account = accounts.first { $0.name == "Bank" } ?? accounts.first!
        transaction2.amount = 14444.0
        transaction2.type = 1
        transaction2.note = "Salary + Bonus"

        let transaction3 = Transaction(context: context)
        transaction3.id = UUID()
        transaction3.title = "Snacks"
        transaction3.date = Date().addingTimeInterval(-100_000)
        transaction3.category = categories.first { $0.name == "Food" } ?? categories.last!
        transaction3.account = accounts.first { $0.name == "Cash" } ?? accounts.first!
        transaction3.amount = 20.0
        transaction3.type = 0
        transaction3.note = "Consumed tea with Mr. Maruf."

        return [transaction1, transaction2, transaction3]
    }}

    var accounts: (NSManagedObjectContext) -> [Account] {{ context in
        let accountNames = ["Cash", "Card", "Bank"]
        var accounts: [Account] = []
        for name in accountNames {
            let acct = Account(context: context)
            acct.id = UUID()
            acct.name = name
            accounts.append(acct)
        }
        return accounts
    }}
}
