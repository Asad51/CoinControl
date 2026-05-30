//
//  CategoryService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol CategoryServiceProtocol {
    func fetchCategories() throws -> [Category]
    func fetchCategories(by type: Int16) throws -> [Category]
    func addCategory(name: String, icon: String, type: Int16) throws
    func deleteCategory(_ category: Category) throws
}

class CategoryService: CategoryServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchCategories() throws -> [Category] {
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return try context.fetch(request)
    }

    func fetchCategories(by type: Int16) throws -> [Category] {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "type == %d", type)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        return try context.fetch(request)
    }

    func addCategory(name: String, icon: String, type: Int16) throws {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.type = type
        
        try context.save()
    }

    func deleteCategory(_ category: Category) throws {
        context.delete(category)
        try context.save()
    }
}
