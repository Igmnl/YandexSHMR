//
//  Transaction.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

import Foundation

struct Transaction {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
}
