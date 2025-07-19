//
//  BankAccount.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

final class BankAccountService {
    private let networkClient: NetworkClient
    private let storage: BankAccountStorage
    private let backupStorage: BankAccountBackupStorage
    
    init(
        networkClient: NetworkClient = .shared,
        storage: BankAccountStorage = SwiftDataBankAccountStorage(),
        backupStorage: BankAccountBackupStorage = SwiftDataBankAccountBackupStorage()
    ) {
        self.networkClient = networkClient
        self.storage = storage
        self.backupStorage = backupStorage
    }
    
    func bankAccount() async throws -> BankAccount {
        try await syncPendingAccountUpdates()
        
        do {
            let accounts: [BankAccount] = try await networkClient.requets(
                method: .get,
                path: "/accounts"
            )
            
            guard let account = accounts.first else {
                throw NSError(domain: "No accounts found", code: 0)
            }
            
            try await storage.saveAccount(account)
            return account
        } catch {
            if let localAccount = try await storage.getAccount() {
                return localAccount
            }
            throw error
        }
    }
    
    func changeBankAccount(id: Int, name: String, balance: Decimal, currency: String) async throws {
        let updateRequest = AccountUpdateRequest(
            name: name,
            balance: balance.description,
            currency: currency
        )
        
        do {
            let account: BankAccount = try await networkClient.requets(
                method: .put,
                path: "/accounts/\(id)",
                body: updateRequest
            )
            
            try await storage.saveAccount(account)
            
            try await backupStorage.removePendingUpdates([id])
        } catch {
            let pendingUpdate = PendingAccountUpdate(
                accountId: id,
                name: name,
                balance: balance,
                currency: currency
            )
            try await backupStorage.savePendingUpdate(pendingUpdate)
            throw error
        }
    }
    
    private func syncPendingAccountUpdates() async throws {
        let pendingUpdates = try await backupStorage.getPendingUpdates()
        
        for update in pendingUpdates {
            do {
                let updateRequest = AccountUpdateRequest(
                    name: update.name,
                    balance: update.balance.description,
                    currency: update.currency
                )
                
                let _:BankAccount = try await networkClient.requets(
                    method: .put,
                    path: "/accounts/\(update.accountId)",
                    body: updateRequest
                )
                
                try await backupStorage.removePendingUpdates([update.accountId])
            } catch {
                continue
            }
        }
    }
}
