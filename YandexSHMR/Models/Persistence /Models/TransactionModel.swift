//
//  TransactionModel.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

@Model
final class TransactionModel {
    var id: Int
    var accountId: Int
    var categoryId: Int
    var amount: Decimal
    var transactionDate: Date
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    init(id: Int, accountId: Int, categoryId: Int,
         amount: Decimal, transactionDate: Date,
         comment: String, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.accountId = accountId
        self.categoryId = categoryId
        self.amount = amount
        self.transactionDate = transactionDate
        self.comment = comment
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    func toResponse(account: BankAccountBrief, category: Category) -> TransactionResponse {
        return TransactionResponse(
            id: id,
            account: account,
            category: category,
            amount: amount,
            transactionDate: transactionDate,
            comment: comment,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}


extension TransactionModel {
    func update(from response: TransactionResponse) {
        self.amount = response.amount
        self.comment = response.comment ?? ""
        self.transactionDate = response.transactionDate
        self.categoryId = response.category.id
        self.accountId = response.account.id
        self.updatedAt = Date()
    }
}
