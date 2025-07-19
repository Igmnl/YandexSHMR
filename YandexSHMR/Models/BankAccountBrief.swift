//
//  BankAccountBrief.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

struct BankAccountBrief: Equatable, Hashable, Codable {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
    
    init(id: Int, name: String, balance: Decimal, currency: String) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currency = currency
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        let balance = try container.decode(String.self, forKey: .balance)
        self.balance = Decimal(string: balance) ?? 0
        self.currency = try container.decode(String.self, forKey: .currency)
    }
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        let str = balance.description
        try container.encode(str, forKey: .balance)
        try container.encode(currency, forKey: .currency)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case balance
        case currency
    }
}
