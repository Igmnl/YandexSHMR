//
//  TransactionBackupStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation


protocol TransactionBackupStorage {
    func getPendingOperations() async throws -> [PendingTransactionOperation]
    func addPendingOperation(_ operation: PendingTransactionOperation) async throws
    func removePendingOperations(_ ids: [Int]) async throws
}
