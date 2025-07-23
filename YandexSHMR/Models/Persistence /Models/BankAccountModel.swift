//
//  BankAccountModel.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class BankAccountModel {
    var id: Int
    var userId: Int
    var name: String
    var balance: Decimal
    var currency: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, userId: Int, name: String,
         balance: Decimal, currency: String,
         createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.balance = balance
        self.currency = currency
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    convenience init(from account: BankAccount) {
        self.init(
            id: account.id,
            userId: account.userId,
            name: account.name,
            balance: account.balance,
            currency: account.currency,
            createdAt: account.createdAt,
            updatedAt: account.updatedAt
        )
    }
    
    func toDomain() -> BankAccount {
        BankAccount(
            id: id,
            userId: userId,
            name: name,
            balance: balance,
            currency: currency,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
