//
//  Category.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

struct Category: Equatable, Identifiable, Hashable {
    var id: Int
    var name: String
    var emoji: Character
    var isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
}

enum Direction {
    case income
    case outcome
}
