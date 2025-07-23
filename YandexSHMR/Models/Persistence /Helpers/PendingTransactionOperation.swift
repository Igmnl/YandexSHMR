//
//  PendingTransactionOperation.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation

enum TransactionOperationType: Codable {
    case create
    case update
    case delete
}

struct PendingTransactionOperation: Codable {
    let operationType: TransactionOperationType
    let transaction: TransactionResponse
    let accountUpdate: BankAccountBrief?
    let id: Int
    
    init(operationType: TransactionOperationType,
         transaction: TransactionResponse,
         accountUpdate: BankAccountBrief? = nil) {
        self.operationType = operationType
        self.transaction = transaction
        self.accountUpdate = accountUpdate
        self.id = transaction.id
    }
}
