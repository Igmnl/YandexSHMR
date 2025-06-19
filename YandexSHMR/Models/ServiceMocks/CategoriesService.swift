//
//  CategoriesService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class CategoriesService {
    func categories() async throws -> [Category] {
        [
            Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
            Category(id: 2, name: "Премия", emoji: "💵", isIncome: true),
            Category(id: 3, name: "Транспорт", emoji: "🚌", isIncome: false),
            Category(id: 4, name: "Еда", emoji: "🍔", isIncome: false),
        ]
    }
    
    func categories(for direction: Direction) async throws -> [Category] {
        let categories = try await categories()
        
        return categories.filter { category in
            category.direction == direction
        }
    }
}
