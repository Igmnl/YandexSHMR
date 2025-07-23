//
//  CategoryModel.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class CategoryModel {
    var id: Int
    var name: String
    var emoji: String
    var isIncome: Bool
    
    init(id: Int, name: String, emoji: Character, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = String(emoji)
        self.isIncome = isIncome
    }
    
    convenience init(from category: Category) {
        self.init(
            id: category.id,
            name: category.name,
            emoji: category.emoji,
            isIncome: category.isIncome
        )
    }
    
    func toDomain() -> Category {
        Category(
            id: id,
            name: name,
            emoji: emoji.first ?? " ",
            isIncome: isIncome
        )
    }
}
