//
//  BankAccountStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation

protocol BankAccountStorage {
    func saveAccount(_ account: BankAccount) async throws
    func getAccount() async throws -> BankAccount?
}
