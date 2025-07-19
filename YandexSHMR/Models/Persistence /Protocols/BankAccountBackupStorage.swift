//
//  BankAccountBackupStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation

protocol BankAccountBackupStorage {
    func savePendingUpdate(_ update: PendingAccountUpdate) async throws
    func getPendingUpdates() async throws -> [PendingAccountUpdate]
    func removePendingUpdates(_ ids: [Int]) async throws
}
