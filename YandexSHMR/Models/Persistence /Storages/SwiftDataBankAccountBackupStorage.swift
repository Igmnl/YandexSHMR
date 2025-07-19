//
//  SwiftDataBankAccountBackupStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

final class SwiftDataBankAccountBackupStorage: BankAccountBackupStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: PendingAccountUpdateModel.self,
                configurations: ModelConfiguration("AccountsBackupDB")
            )
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize BankAccount backup storage: \(error)")
        }
    }
    
    func savePendingUpdate(_ update: PendingAccountUpdate) async throws {
        if let existing = try? getModel(by: update.accountId) {
            modelContext.delete(existing)
        }
        
        let model = PendingAccountUpdateModel(from: update)
        modelContext.insert(model)
        try modelContext.save()
    }
    
    func getPendingUpdates() async throws -> [PendingAccountUpdate] {
        let descriptor = FetchDescriptor<PendingAccountUpdateModel>()
        let models = try modelContext.fetch(descriptor)
        return models.map { $0.toDomain() }
    }
    
    func removePendingUpdates(_ ids: [Int]) async throws {
        for id in ids {
            if let model = try? getModel(by: id) {
                modelContext.delete(model)
            }
        }
        try modelContext.save()
    }
    
    private func getModel(by id: Int) throws -> PendingAccountUpdateModel? {
        let predicate = #Predicate<PendingAccountUpdateModel> { $0.accountId == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
}
