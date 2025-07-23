//
//  TransactionRequest.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 18.07.2025.
//

import Foundation

struct TransactionRequest: Codable {
    var accountId: Int
    var categoryId: Int
    var amount: String
    var transactionDate: String
    var comment: String
}
