//
//  TransactionCSVExtension.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

extension Transaction {
    var csvObject: String {
        "\(id),\(accountId),\(categoryId),\(amount.description),\(transactionDate),\(comment ?? ""),\(createdAt),\(updatedAt)"
    }
    
    static func parseCsv(csv: String) -> Transaction? {
        let components = csv.components(separatedBy: ",")
        
        guard let id = Int(components[0].trimmingCharacters(in: .whitespaces)),
              let accountId = Int(components[1].trimmingCharacters(in: .whitespaces)),
              let categoryId = Int(components[2].trimmingCharacters(in: .whitespaces)),
              let amount = Decimal(string: components[3].trimmingCharacters(in: .whitespaces)),
              let transactionDate = dateFormatter.date(from: components[4].trimmingCharacters(in: .whitespaces)),
              let createdAt = dateFormatter.date(from: components[6].trimmingCharacters(in: .whitespaces)),
              let updatedAt = dateFormatter.date(from: components[7].trimmingCharacters(in: .whitespaces)) else {
            print("Incorrect data in csv")
            return nil
        }
        
        let comment = components[5].isEmpty ? nil : components[5].trimmingCharacters(in: .whitespaces)
        
        let transaction = Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate:transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        
        return transaction
        
    }
}
