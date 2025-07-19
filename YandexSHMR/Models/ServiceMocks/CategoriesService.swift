//
//  CategoriesService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class CategoriesService {
    private let networkClient: NetworkClient
    private let storage: CategoriesStorage
    
    init(
        networkClient: NetworkClient = .shared,
        storage: CategoriesStorage = SwiftDataCategoriesStorage()
    ) {
        self.networkClient = networkClient
        self.storage = storage
    }
    
    func categories() async throws -> [Category] {
        do {
            let remoteCategories: [Category] = try await networkClient.requets(
                method: .get,
                path: "/categories"
            )
            
            try await storage.saveCategories(remoteCategories)
            return remoteCategories
        } catch {
            return try await storage.getCategories()
        }
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        let categories = try await categories()
        return categories.filter { $0.direction == direction }
    }
}
