//
//  SwiftDataBankAccountStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

final class SwiftDataBankAccountStorage: BankAccountStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: BankAccountModel.self,
                configurations: ModelConfiguration("AccountsDB")
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize BankAccount storage: \(error)")
        }
    }
    
    func saveAccount(_ account: BankAccount) async throws {
        if let existing = try? getModel() {
            existing.name = account.name
            existing.balance = account.balance
            existing.currency = account.currency
            existing.updatedAt = Date()
        } else {
            let model = BankAccountModel(from: account)
            modelContext.insert(model)
        }
        try modelContext.save()
    }
    
    func getAccount() async throws -> BankAccount? {
        try getModel()?.toDomain()
    }
    
    private func getModel() throws -> BankAccountModel? {
        let descriptor = FetchDescriptor<BankAccountModel>()
        return try modelContext.fetch(descriptor).first
    }
}
