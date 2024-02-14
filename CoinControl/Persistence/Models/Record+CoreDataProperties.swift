//
//  Record+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 14/2/24.
//
//

import CoreData
import Foundation

public extension Record {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Record> {
        return NSFetchRequest<Record>(entityName: "Record")
    }

    @NSManaged var date: Date
    @NSManaged var account: String
    @NSManaged var amount: Double
    @NSManaged var note: String
    @NSManaged var recordDescription: String?
    @NSManaged var category: Category
}

extension Record: Identifiable {}
