//
//  TransactionJSONExtension.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

extension TransactionResponse {
    static func parse(jsonObject: Any) -> TransactionResponse? {
        guard let dictionary = jsonObject as? [String: Any],
              let id = dictionary["id"] as? Int,
              let account = dictionary["account"] as? BankAccountBrief,
              let category = dictionary["category"] as? Category,
              let amountString = dictionary["amount"] as? String,
              let amount = Decimal(string: amountString),
              let transactionDateString = dictionary["transactionDate"] as? String,
              let createdAtString = dictionary["createdAt"] as? String,
              let updatedAtString = dictionary["updatedAt"] as? String else {
            print("Invalid data in json")
            return nil
        }
        
        let comment = dictionary["comment"] as? String
        
        guard let transactionDate = dateFormatter.date(from: transactionDateString),
              let createdAt = dateFormatter.date(from: createdAtString),
              let updatedAt = dateFormatter.date(from: updatedAtString) else {
            print("Invalid dates")
            return nil
        }
        
        return TransactionResponse(id: id, account: account, category: category, amount: amount, transactionDate: transactionDate, comment: comment, createdAt: createdAt, updatedAt: updatedAt)
    }
    
    
    var jsonObject: Any {
        var dict: [String : Any] =  [
            "id": id,
            "account": account,
            "category": category,
            "amount": amount.description,
            "transactionDate": TransactionResponse.dateFormatter.string(from: transactionDate),
            "createdAt": TransactionResponse.dateFormatter.string(from: createdAt),
            "updatedAt": TransactionResponse.dateFormatter.string(from: updatedAt)
        ]
        
        if let comment {
            dict.updateValue(comment, forKey: "comment")
        }
        
        return dict
    }
}
