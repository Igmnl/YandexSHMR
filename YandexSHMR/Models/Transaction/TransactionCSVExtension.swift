//
//  TransactionCSVExtension.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

extension TransactionResponse {
    var csvObject: String {
        let transactionDate = TransactionResponse.dateFormatter.string(from: transactionDate)
        let createdAt = TransactionResponse.dateFormatter.string(from: createdAt)
        let updatedAt = TransactionResponse.dateFormatter.string(from: updatedAt)
        let accountString = "\(account.id),\(account.name),\(account.balance),\(account.currency)"
        let categoryString = "\(category.id),\(category.name),\(category.emoji),\(category.isIncome)"
        return "\(id),\(accountString),\(categoryString),\(amount.description),\(transactionDate),\(comment ?? ""),\(createdAt),\(updatedAt)"
    }
    
    static func parseCsv(csv: String) -> TransactionResponse? {
        let components = csv.components(separatedBy: ",")
        
        guard let accountId = Int(components[1].trimmingCharacters(in: .whitespaces)),
              let balance = Decimal(string: components[3].trimmingCharacters(in: .whitespaces)) else {
            print("Error: can`t convert data to account")
            return nil
        }
        
        let bankAccount = BankAccountBrief(id: accountId, name: components[2], balance: balance, currency: components[4])
        
        guard let categoryid = Int(components[5].trimmingCharacters(in: .whitespaces)),
              let isIncome = Bool(components[8].trimmingCharacters(in: .whitespaces)) else {
            print("Error: can`t convert data to category")
            return nil
        }
        
        let category = Category(id: categoryid, name: components[6], emoji: Character(components[7]), isIncome: isIncome)
              
        guard let id = Int(components[0].trimmingCharacters(in: .whitespaces)),
              let amount = Decimal(string: components[9].trimmingCharacters(in: .whitespaces)),
              let transactionDate = dateFormatter.date(from: components[10].trimmingCharacters(in: .whitespaces)),
              let createdAt = dateFormatter.date(from: components[12].trimmingCharacters(in: .whitespaces)),
              let updatedAt = dateFormatter.date(from: components[13].trimmingCharacters(in: .whitespaces)) else {
            print("Incorrect data in csv")
            return nil
        }
        
        let comment = components[11].isEmpty ? nil : components[5].trimmingCharacters(in: .whitespaces)
        
        let transaction = TransactionResponse(id: id, account: bankAccount, category: category, amount: amount, transactionDate:transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        
        return transaction
        
    }
}
