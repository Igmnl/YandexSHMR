//
//  Transaction.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.06.2025.
//

import Foundation

struct Transaction: Identifiable, Hashable {
    var id: Int
    var account: BankAccountBrief
    var category: Category
    var amount: Decimal
    var transactionDate: Date
    var comment: String?
    let createdAt: Date
    var updatedAt: Date
}
