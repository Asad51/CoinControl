//
//  PreviewData.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 15/2/24.
//

import CoreData
import Foundation

struct PreviewData {
    var record: (NSManagedObjectContext) -> Record {{ context in
        let category = Category(context: context)
        category.name = "Groceries"
        category.slug = "groceries"

        let record = Record(context: context)
        record.date = Date().addingTimeInterval(-100_000)
        record.category = category
        record.account = "Cash"
        record.amount = 10.61
        record.note = "Chicken"
        record.recordDescription = "Bought 6kgs of chicken."

        return record
    }}

    var records: (NSManagedObjectContext) -> [Record] {{ context in
        let record = Record(context: context)
        record.date = Date().addingTimeInterval(-100_000)
        record.account = "Accounts"
        record.amount = 12.0
        record.note = "Tea"
        record.recordDescription = "Consumed tea with Mr. Maruf."

        return [record]
    }}
}
