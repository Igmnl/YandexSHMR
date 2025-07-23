//
//  Category.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

import Foundation

struct Category: Codable, Equatable, Identifiable, Hashable {
    var id: Int
    var name: String
    var emoji: Character
    var isIncome: Bool
    
    var direction: Direction {
        isIncome ? .income : .outcome
    }
    
    init (id: Int, name: String, emoji: Character, isIncome: Bool) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.isIncome = isIncome
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        let emojiStr = try container.decode(String.self, forKey: .emoji)
        if emojiStr.count == 1 {
            emoji = Character(emojiStr)
        } else {
            throw CodableError.FailedDecodingEmoji
        }
        isIncome = try container.decode(Bool.self, forKey: .isIncome)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let str = String(emoji)
        try container.encode(str, forKey: .emoji)
        try container.encode(isIncome, forKey: .isIncome)
    }
    
    enum CodableError: Error {
        case FailedDecodingEmoji
    }
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case emoji
        case isIncome
    }
}

enum Direction {
    case income
    case outcome
}
