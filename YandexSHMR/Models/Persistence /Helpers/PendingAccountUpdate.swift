//
//  PendingAccountUpdate.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation

struct PendingAccountUpdate: Codable {
    let accountId: Int
    let name: String
    let balance: Decimal
    let currency: String
}
