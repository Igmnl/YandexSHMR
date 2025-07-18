//
//  BankAccount.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

import Foundation

struct BankAccount: Codable {
    var id: Int
    var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    let createdAt: Date
    var updatedAt: Date
    
    init(id: Int, userId: Int, name: String, balance: Decimal, currency: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        currency = try container.decode(String.self, forKey: .currency)
        
        if let stringValue = try? container.decode(String.self, forKey: .balance),
           let decimalValue = Decimal(string: stringValue) {
            balance = decimalValue
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .balance,
                in: container,
                debugDescription: "Balance could not be parsed as Decimal, String, Double, or Int"
            )
        }
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        let updatedAtString = try container.decode(String.self, forKey: .updatedAt)
        
        guard let createdAtDate = Transaction.dateFormatter.date(from: createdAtString),
              let updatedAtDate = Transaction.dateFormatter.date(from: updatedAtString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match expected format"
            )
        }
        
        createdAt = createdAtDate
        updatedAt = updatedAtDate
    }
}
