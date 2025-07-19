//
//  PendingTransactionOperationModel.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class PendingTransactionOperationModel {
    var operationId: Int
    var operationTypeRaw: String
    var transactionData: Data
    var accountUpdateData: Data?
    var createdAt: Date
    
    init(operation: PendingTransactionOperation) throws {
        self.operationId = operation.id
        self.createdAt = Date()
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .formatted(TransactionResponse.dateFormatter)
        
        switch operation.operationType {
        case .create: operationTypeRaw = "create"
        case .update: operationTypeRaw = "update"
        case .delete: operationTypeRaw = "delete"
        }
        
        self.transactionData = try encoder.encode(operation.transaction)
        
        if let accountUpdate = operation.accountUpdate {
            self.accountUpdateData = try encoder.encode(accountUpdate)
        }
    }
    
    func toPendingOperation() throws -> PendingTransactionOperation {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(TransactionResponse.dateFormatter)
        
        let operationType: TransactionOperationType
        switch operationTypeRaw {
        case "create": operationType = .create
        case "update": operationType = .update
        case "delete": operationType = .delete
        default: throw DecodingError.dataCorrupted(.init(codingPath: [], debugDescription: "Invalid operation type"))
        }
        
        let transaction = try decoder.decode(TransactionResponse.self, from: transactionData)
        
        let accountUpdate: BankAccountBrief?
        if let accountUpdateData = accountUpdateData {
            accountUpdate = try decoder.decode(BankAccountBrief.self, from: accountUpdateData)
        } else {
            accountUpdate = nil
        }
        
        return PendingTransactionOperation(
            operationType: operationType,
            transaction: transaction,
            accountUpdate: accountUpdate
        )
    }
}

