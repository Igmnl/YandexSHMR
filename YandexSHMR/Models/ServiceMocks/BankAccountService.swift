//
//  BankAccount.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class BankAccountService {
    var account = BankAccount(id: 1, userId: 1, name: "Основной счет", balance: 500, currency: "RUB", createdAt: .now, updatedAt: .now)
    
    func bankAccount() async throws -> BankAccount {
        account
    }
    
    func changeBankAccount(name: String?, balance: Decimal?, currency: String?) async throws {
        if let name {
            account.name = name
            account.updatedAt = .now
        }
       
        if let balance {
            account.balance = balance
            account.updatedAt = .now
        }
        
        if let currency {
            account.currency = currency
            account.updatedAt = .now
        }
    }
}
