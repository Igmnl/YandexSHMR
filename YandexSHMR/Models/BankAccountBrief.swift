//
//  BankAccountBrief.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

struct BankAccountBrief: Equatable, Hashable {
    var id: Int
    var name: String
    var balance: Decimal
    var currency: String
}
