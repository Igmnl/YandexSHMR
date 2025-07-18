//
//  CategoriesService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class CategoriesService {
    func categories() async throws -> [Category] {
        try await NetworkClient.shared.requets(method: .get, path: "/categories")
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        let categories = try await categories()
        
        return categories.filter { category in
            category.direction == direction
        }
    }
}
