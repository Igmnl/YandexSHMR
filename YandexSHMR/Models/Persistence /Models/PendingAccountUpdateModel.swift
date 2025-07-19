//
//  PendingAccountUpdateModel.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class PendingAccountUpdateModel {
    var accountId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    
    init(accountId: Int, name: String, balance: Decimal, currency: String, createdAt: Date) {
        self.accountId = accountId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
    }
    
    convenience init(from update: PendingAccountUpdate) {
        self.init(
            accountId: update.accountId,
            name: update.name,
            balance: update.balance,
            currency: update.currency,
            createdAt: Date()
        )
    }
    
    func toDomain() -> PendingAccountUpdate {
        PendingAccountUpdate(
            accountId: accountId,
            name: name,
            balance: balance,
            currency: currency
        )
    }
}

