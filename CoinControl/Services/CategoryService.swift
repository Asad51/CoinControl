//
//  CategoryService.swift
//  CoinControl
//

import CoreData
import Foundation

protocol CategoryServiceProtocol {
    func fetchCategories() throws -> [CategoryModel]
    func fetchCategories(by type: Int16) throws -> [CategoryModel]
    func addCategory(name: String, icon: String, type: Int16) throws
    func deleteCategory(_ category: CategoryModel) throws
}

class CategoryService: CategoryServiceProtocol {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
    }

    func fetchCategories() throws -> [CategoryModel] {
        let request = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        let categories = try context.fetch(request)
        return categories.map { $0.toModel }
    }

    func fetchCategories(by type: Int16) throws -> [CategoryModel] {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "type == %d", type)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        let categories = try context.fetch(request)
        return categories.map { $0.toModel }
    }

    func addCategory(name: String, icon: String, type: Int16) throws {
        let category = Category(context: context)
        category.id = UUID()
        category.name = name
        category.icon = icon
        category.type = type

        try context.save()
    }

    func deleteCategory(_ categoryModel: CategoryModel) throws {
        let request = Category.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", categoryModel.id as CVarArg)
        if let category = try context.fetch(request).first {
            context.delete(category)
            try context.save()
        }
    }
}
