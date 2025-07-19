//
//  TransactionStorageProtocol.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 18.07.2025.
//

import Foundation
import SwiftData

protocol TransactionStorage {
    func getAllTransactions() async throws -> [TransactionResponse]
    func updateTransaction(_ transaction: TransactionResponse) async throws
    func deleteTransaction(id: Int) async throws
    func createTransaction(_ transaction: TransactionResponse) async throws
}

