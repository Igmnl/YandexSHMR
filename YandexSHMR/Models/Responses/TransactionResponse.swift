//
//  TransactionResponse.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 18.07.2025.
//

import Foundation

struct TransactionResponse: Decodable {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    enum CodingKeys: CodingKey {
        case id
        case accountId
        case categoryId
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.accountId = try container.decode(Int.self, forKey: .accountId)
        self.categoryId = try container.decode(Int.self, forKey: .categoryId)
        let amnt = try container.decode(String.self, forKey: .amount)
        self.amount = Decimal(string: amnt) ?? 0
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
}
