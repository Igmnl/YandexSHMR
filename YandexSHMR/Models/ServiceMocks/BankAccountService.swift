//
//  BankAccount.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class BankAccountService {
    func bankAccount() async throws -> BankAccount {
        let accounts: [BankAccount] = try await NetworkClient.shared.requets(method: .get, path: "/accounts")
        
        guard let firstAccount = accounts.first else {
            throw NSError(domain: "No accounts found", code: 0)
        }
        return firstAccount
    }
    
    func changeBankAccount(id: Int, name: String, balance: Decimal, currency: String) async throws {
        let _: BankAccount = try await NetworkClient.shared.requets(method: .put, path: "/accounts/\(id)", body: AccountUpdateRequest(name: name, balance: balance.description, currency: currency))
    }
}
