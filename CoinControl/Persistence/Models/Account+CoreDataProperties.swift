//
//  Account+CoreDataProperties.swift
//  CoinControl
//
//  Created by Md. Asadul Islam on 19/4/26.
//
//

import CoreData
import Foundation

public typealias AccountCoreDataPropertiesSet = NSSet

extension Account {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Account> {
        NSFetchRequest<Account>(entityName: "AccountEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged var name: String
}

extension Account: Identifiable {}
