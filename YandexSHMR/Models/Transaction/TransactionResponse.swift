//
//  Transaction.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

import Foundation

struct TransactionResponse: Identifiable, Hashable, Codable {
    var id: Int
    var account: BankAccountBrief
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
    
    
    init(id: Int, account: BankAccountBrief, category: Category, amount: Decimal, transactionDate: Date, comment: String? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.account = account
        self.category = category
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.account = try container.decode(BankAccountBrief.self, forKey: .account)
        self.category = try container.decode(Category.self, forKey: .category)
        let amount = try container.decode(String.self, forKey: .amount)
        self.amount = Decimal(string: amount) ?? 0
        self.transactionDate = try container.decode(Date.self, forKey: .transactionDate)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.updatedAt = try container.decode(Date.self, forKey: .updatedAt)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(account, forKey: .account)
        try container.encode(category, forKey: .category)
        try container.encode(amount.description, forKey: .amount)
        try container.encode(transactionDate, forKey: .transactionDate)
        try container.encodeIfPresent(comment, forKey: .comment)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case account
        case category
        case amount
        case transactionDate
        case comment
        case createdAt
        case updatedAt
    }
}
