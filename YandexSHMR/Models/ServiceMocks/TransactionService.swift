//
//  TransactionService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation
import SwiftData

final class TransactionService {
    private let networkClient: NetworkClient
    private let localStorage: SwiftDataTransactionStorage
    private let backupStorage: SwiftDataBackupStorage
    private let accountService: BankAccountService
    
    
    init(
        networkClient: NetworkClient = .shared,
        localStorage: SwiftDataTransactionStorage = SwiftDataTransactionStorage(),
        backupStorage: SwiftDataBackupStorage = SwiftDataBackupStorage(),
        accountService: BankAccountService = .init()
    ) {
        self.networkClient = networkClient
        self.localStorage = localStorage
        self.backupStorage = backupStorage
        self.accountService = accountService
    }
    
    func initialSync() async {
        do {
            try await syncPendingOperations()
        } catch {
            print("Initial sync failed: \(error)")
        }
    }
    
    func transactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [TransactionResponse] {
        try? await syncPendingOperations()
        
        do {
            let remote = try await fetchRemoteTransactions(accountId: accountId, startDate: startDate, endDate: endDate)
            try await localStorage.saveTransactions(remote, forPeriod: startDate, endDate: endDate)
            return remote
        } catch {
            let local = try await localStorage.getTransactions(for: accountId, startDate: startDate, endDate: endDate)
            let pendingOps = try await backupStorage.getPendingOperations()
            
            let merged = mergeTransactions(local: local, pending: pendingOps, accountId: accountId, startDate: startDate, endDate: endDate)

            return merged
        }
    }
    
    private func mergeAllTransactions(
        local: [TransactionResponse],
        pending: [TransactionResponse],
        accountId: Int,
        startDate: Date,
        endDate: Date
    ) -> [TransactionResponse] {
        let filteredPending = pending.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
        var allTransactions = local + filteredPending
        allTransactions = allTransactions.unique(by: \.id)
        return allTransactions.sorted { $0.transactionDate > $1.transactionDate }
    }
    
    func createTransaction(transaction: TransactionResponse) async throws {
        let duplicateKey = "\(transaction.amount)-\(transaction.transactionDate.timeIntervalSince1970)-\(transaction.category.id)"
        
        let allLocal = try await localStorage.getAllTransactions()
        let isDuplicate = allLocal.contains { tx in
            let txKey = "\(tx.amount)-\(tx.transactionDate.timeIntervalSince1970)-\(tx.category.id)"
            return txKey == duplicateKey
        }
        
        guard !isDuplicate else {
            print("Обнаружен дубликат транзакции, пропускаем создание")
            return
        }
        
        do {
            let createdTransaction = try await performCreateTransaction(transaction)
            try await localStorage.createTransaction(createdTransaction)
            try await backupStorage.removePendingOperations([transaction.id])
        } catch {
            let temporaryId = -Int(Date().timeIntervalSince1970)
            
            let offlineTransaction = TransactionResponse(
                id: temporaryId,
                account: transaction.account,
                category: transaction.category,
                amount: transaction.amount,
                transactionDate: transaction.transactionDate,
                comment: transaction.comment,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            let pendingOps = try await backupStorage.getPendingOperations()
            let existsInBackup = pendingOps.contains { $0.transaction.id == temporaryId }
            
            if !existsInBackup {
                try await localStorage.createTransaction(offlineTransaction)
                
                let operation = PendingTransactionOperation(
                    operationType: .create,
                    transaction: offlineTransaction
                )
                try await backupStorage.addPendingOperation(operation)
            }
        }
    }
    
    func updateTransaction(transaction: TransactionResponse) async throws {
        guard (try? await localStorage.getTransaction(id: transaction.id)) != nil else {
            throw TransactionServiceError.transactionNotFound
        }
        
        do {
            let updatedTransaction = try await performUpdateTransaction(transaction)
            
            try await localStorage.updateTransaction(updatedTransaction)
            
            try await backupStorage.removePendingOperations([transaction.id])
        } catch {
            let operation = PendingTransactionOperation(
                operationType: .update,
                transaction: transaction
            )
            
            try await backupStorage.addPendingOperation(operation)
            try await localStorage.updateTransaction(transaction)
            
            throw error 
        }
    }
    
    func deleteTransaction(transactionId: Int) async throws {
        guard let transaction = try? await localStorage.getTransaction(id: transactionId) else {
            return
        }
        
        try await localStorage.deleteTransaction(id: transactionId)
        
        do {
            try await performDeleteTransaction(transactionId)
            try await backupStorage.removePendingOperations([transactionId])
        } catch {
            let operation = PendingTransactionOperation(
                operationType: .delete,
                transaction: transaction
            )
            try await backupStorage.addPendingOperation(operation)
        }
    }
    
    private func mergeTransactions(
        local: [TransactionResponse],
        pending: [PendingTransactionOperation],
        accountId: Int,
        startDate: Date,
        endDate: Date
    ) -> [TransactionResponse] {
        let relevantPending = pending.filter { op in
            let tx = op.transaction
            return tx.account.id == accountId &&
            tx.transactionDate >= startDate &&
            tx.transactionDate <= endDate
        }
        
        var createOrUpdateOps = [TransactionResponse]()
        var deleteIds = Set<Int>()
        
        for op in relevantPending {
            switch op.operationType {
            case .create, .update:
                createOrUpdateOps.append(op.transaction)
            case .delete:
                deleteIds.insert(op.id)
            }
        }
        
        let filteredLocal = local.filter { !deleteIds.contains($0.id) }
        
        let allTransactions = (filteredLocal + createOrUpdateOps).reduce(into: [Int: TransactionResponse]()) { result, tx in
            result[tx.id] = tx
        }.values
        
        let uniqueTransactions = allTransactions.reduce(into: [String: TransactionResponse]()) { result, tx in
            let key = "\(tx.amount)-\(tx.transactionDate.timeIntervalSince1970)-\(tx.category.id)"
            result[key] = tx
        }.values
        
        return Array(uniqueTransactions).sorted { $0.transactionDate > $1.transactionDate }
    }
    
    private func syncPendingOperations() async throws {
        let pendingOperations = try await backupStorage.getPendingOperations()
        
        var operationsToRemove = [Int]()
        
        for operation in pendingOperations {
            do {
                switch operation.operationType {
                case .create:
                    if (try? await localStorage.getTransaction(id: operation.id)) == nil {
                        let createdTransaction = try await performCreateTransaction(operation.transaction)
                        try await localStorage.createTransaction(createdTransaction)
                    }
                    try await backupStorage.removePendingOperations([operation.id])
                    
                case .update:
                    if (try? await localStorage.getTransaction(id: operation.id)) != nil {
                        _ = try await performUpdateTransaction(operation.transaction)
                        try await localStorage.updateTransaction(operation.transaction)
                        operationsToRemove.append(operation.id)
                    } else {
                        try await performCreateTransaction(operation.transaction)
                        operationsToRemove.append(operation.id)
                    }
                    
                case .delete:
                    do {
                        try await performDeleteTransaction(operation.id)
                        operationsToRemove.append(operation.id)
                    } catch NetworkError.notFound {
                        operationsToRemove.append(operation.id)
                        try await localStorage.deleteTransaction(id: operation.id)
                    }
                }
            } catch {
                print("Ошибка синхронизации операции \(operation.id): \(error)")
                
                // Помечаем проблемные операции для последующей обработки
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .notFound, .invalidDataOrIdentifier:
                        operationsToRemove.append(operation.id)
                    default:
                        break
                    }
                }
            }
        }
        
        try await backupStorage.removePendingOperations(operationsToRemove)
    }
    
    
    private func fetchRemoteTransactions(
        accountId: Int,
        startDate: Date,
        endDate: Date
    ) async throws -> [TransactionResponse] {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.formatOptions = [.withFullDate]
        
        let startDateStr = dateFormatter.string(from: startDate)
        let endDateStr = dateFormatter.string(from: endDate)
        
        return try await networkClient.requets(
            method: .get,
            path: "/transactions/account/\(accountId)/period?startDate=\(startDateStr)&endDate=\(endDateStr)"
        )
    }
    
    private func performCreateTransaction(_ transaction: TransactionResponse) async throws -> TransactionResponse {
        if let existing = try? await localStorage.getTransaction(id: transaction.id) {
            return existing
        }
        let formatedDate = TransactionResponse.dateFormatter.string(from: transaction.transactionDate)
        let newTransaction = TransactionRequest(
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount.description,
            transactionDate: formatedDate,
            comment: transaction.comment ?? ""
        )
        
        let created: Transaction = try await networkClient.requets(
            method: .post,
            path: "/transactions",
            body: newTransaction
        )
        
        return TransactionResponse(
            id: created.id,
            account: transaction.account,
            category: transaction.category,
            amount: created.amount,
            transactionDate: created.transactionDate,
            comment: created.comment,
            createdAt: created.createdAt,
            updatedAt: created.updatedAt
        )
    }
    
    private func performUpdateTransaction(_ transaction: TransactionResponse) async throws -> TransactionResponse {
        let formatedDate = TransactionResponse.dateFormatter.string(from: transaction.transactionDate)
        let updateRequest = TransactionRequest(
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount.description,
            transactionDate: formatedDate,
            comment: transaction.comment ?? ""
        )
        
        return try await networkClient.requets(
            method: .put,
            path: "/transactions/\(transaction.id)",
            body: updateRequest
        )
    }
    
    private func performDeleteTransaction(_ transactionId: Int) async throws {
        let _: DecodableStub = try await networkClient.requets(
            method: .delete,
            path: "/transactions/\(transactionId)"
        )
    }
    
    private func getLocalTransactions(
        accountId: Int,
        startDate: Date,
        endDate: Date
    ) async throws -> [TransactionResponse] {
        let localTransactions = try await localStorage.getTransactions(
            for: accountId,
            startDate: startDate,
            endDate: endDate
        )
        
        let pendingOperations = try await backupStorage.getPendingOperations()
        let pendingTransactions = pendingOperations.map { $0.transaction }
        
        let filteredPending = pendingTransactions.filter {
            $0.account.id == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
        
        var allTransactions = localTransactions + filteredPending
        allTransactions = allTransactions.unique(by: \.id)
        
        return allTransactions.sorted { $0.transactionDate > $1.transactionDate }
    }
    
    enum TransactionServiceError: Error {
        case transactionNotFound
        case deletionFailed(reason: String)
        case syncFailed
    }
}

extension Sequence {
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}

struct DecodableStub: Decodable {}
