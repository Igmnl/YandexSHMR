//
//  SwiftDataCategoriesStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

final class SwiftDataCategoriesStorage: CategoriesStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: CategoryModel.self,
                configurations: ModelConfiguration("CategoriesDB")
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize Categories storage: \(error)")
        }
    }
    
    func saveCategories(_ categories: [Category]) async throws {
        for category in categories {
            if let existing = try?  getModel(by: category.id) {
                existing.name = category.name
                existing.emoji = String(category.emoji)
                existing.isIncome = category.isIncome
            } else {
                let model = CategoryModel(from: category)
                modelContext.insert(model)
            }
        }
        try modelContext.save()
    }
    
    func getCategories() async throws -> [Category] {
        let descriptor = FetchDescriptor<CategoryModel>()
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
    
    private func getModel(by id: Int) throws -> CategoryModel? {
        let predicate = #Predicate<CategoryModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
}
