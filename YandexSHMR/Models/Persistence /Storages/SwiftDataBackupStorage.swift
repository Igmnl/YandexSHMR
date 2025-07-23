//
//  SwiftDataBackupStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

final class SwiftDataBackupStorage: TransactionBackupStorage {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    init() {
        do {
            modelContainer = try ModelContainer(for: PendingTransactionOperationModel.self)
            modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize ModelContainer for PendingTransactionOperationModel: \(error)")
        }
    }
    
    func getPendingOperations() async throws -> [PendingTransactionOperation] {
        let descriptor = FetchDescriptor<PendingTransactionOperationModel>(
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        let models = try modelContext.fetch(descriptor)
        return try models.compactMap { try $0.toPendingOperation() }
    }
    
    func addPendingOperation(_ operation: PendingTransactionOperation) async throws {
        let existing = try await getPendingOperation(by: operation.id)
        if existing != nil {
            try await removePendingOperations([operation.id])
        }
        
        let model = try PendingTransactionOperationModel(operation: operation)
        modelContext.insert(model)
        try modelContext.save()
    }
    
    func removePendingOperations(_ ids: [Int]) async throws {
        for id in ids {
            if let model = try getModel(by: id) {
                modelContext.delete(model)
            }
        }
        try modelContext.save()
    }
    
    
    private func getPendingOperation(by id: Int) async throws -> PendingTransactionOperation? {
        guard let model = try getModel(by: id) else { return nil }
        return try model.toPendingOperation()
    }
    
    private func getModel(by id: Int) throws -> PendingTransactionOperationModel? {
        let predicate = #Predicate<PendingTransactionOperationModel> { $0.operationId == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
}
