//
//  TransactionDateFormatter.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import Foundation

extension Transaction {
    
    static var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return dateFormatter
    }
    
    var formatedTransactionDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self.transactionDate)
    }
}
