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
        let record = Record(context: context)
        record.date = Date().addingTimeInterval(-10000)
        record.account = "Accounts"
        record.amount = 12.0
        record.note = "Tea"
        record.recordDescription = "Consumed tea with Mr. Maruf."

        return record
    }}

    var records: (NSManagedObjectContext) -> [Record] {{ context in
        let record = Record(context: context)
        record.date = Date().addingTimeInterval(-10000)
        record.account = "Accounts"
        record.amount = 12.0
        record.note = "Tea"
        record.recordDescription = "Consumed tea with Mr. Maruf."

        return [record]
    }}
}
