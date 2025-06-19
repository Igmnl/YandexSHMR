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

extension Transaction {
    static func parse(jsonObject: Any) -> Transaction? {
        guard let dictionary = jsonObject as? [String: Any],
              let id = dictionary["id"] as? Int,
              let accountId = dictionary["accountId"] as? Int,
              let categoryId = dictionary["categoryId"] as? Int,
              let amountString = dictionary["amount"] as? String,
              let amount = Decimal(string: amountString),
              let transactionDateString = dictionary["transactionDate"] as? String,
              let createdAtString = dictionary["createdAt"] as? String,
              let updatedAtString = dictionary["updatedAt"] as? String else {
            print("Invalid data in json")
            return nil
        }
        
        let comment = dictionary["comment"] as? String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        
        guard let transactionDate = dateFormatter.date(from: transactionDateString),
              let createdAt = dateFormatter.date(from: createdAtString),
              let updatedAt = dateFormatter.date(from: updatedAtString) else {
            print("Invalid dates")
            return nil
        }
        
        var transaction: Transaction
        transaction = Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
        
        return transaction
    }
    
    
    var jsonObject: Any {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        var dict: [String : Any] =  [
            "id": id,
            "accountId": accountId,
            "categoryId": categoryId,
            "amount": amount.description,
            "transactionDate": dateFormatter.string(from: transactionDate),
            "createdAt": dateFormatter.string(from: createdAt),
            "updatedAt": dateFormatter.string(from: updatedAt)
        ]
        
        if let comment {
            dict.updateValue(comment, forKey: "comment")
        }
        
        return dict
    }
}

extension Transaction {
    var csvObject: String {
        "\(id),\(accountId),\(categoryId),\(amount.description),\(transactionDate),\(comment ?? ""),\(createdAt),\(updatedAt)"
    }
    
    static func parseCsv(csv: String) -> Transaction? {
        
        let components = csv.components(separatedBy: ",")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        
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
