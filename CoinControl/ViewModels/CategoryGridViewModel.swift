//
//  CategoryGridViewModel.swift
//  CoinControl
//

import Combine
import CoreData
import Foundation

class CategoryGridViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let categoryService: CategoryServiceProtocol

    init(categoryService: CategoryServiceProtocol = CategoryService()) {
        self.categoryService = categoryService
        fetchCategories()
    }

    func fetchCategories() {
        do {
            categories = try categoryService.fetchCategories()
        } catch {
            print("Failed to fetch categories: \(error)")
        }
    }
}
