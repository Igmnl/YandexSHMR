//
//  AccountUpdateRequest.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 18.07.2025.
//

import Foundation

struct AccountUpdateRequest: Codable {
    var name: String
    var balance: String
    var currency: String
}
