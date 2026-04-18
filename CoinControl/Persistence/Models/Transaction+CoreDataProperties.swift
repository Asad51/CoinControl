//
//  Transaction+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 18/4/26.
//
//

public import Foundation
public import CoreData


public typealias TransactionCoreDataPropertiesSet = NSSet

extension Transaction {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transaction> {
        return NSFetchRequest<Transaction>(entityName: "TransactionEntity")
    }

    @NSManaged public var title: String
    @NSManaged public var account: String
    @NSManaged public var amount: Double
    @NSManaged public var date: Date
    @NSManaged public var note: String
    @NSManaged public var isExpense: Bool
    @NSManaged public var id: UUID
    @NSManaged public var category: Category

}

extension Transaction : Identifiable {

}
