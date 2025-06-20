//
//  TransactionService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation


final class TransactionService {
    let categories = [
        Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true),
        Category(id: 2, name: "Премия", emoji: "💵", isIncome: true),
        Category(id: 3, name: "Транспорт", emoji: "🚌", isIncome: false),
        Category(id: 4, name: "Еда", emoji: "🍔", isIncome: false),
    ]
    
    let bankAccount = BankAccountBrief(id: 1, name: "Леха", balance: 500.00, currency: "RUB")
    
    var transactions: [Transaction] = []
    
    
    init() {
        self.transactions = [
            Transaction(id: 1, account: bankAccount, category: categories[0], amount: 500000.00, transactionDate: Date.now, comment: "Pensil", createdAt: .now, updatedAt: .now),
            Transaction(id: 2, account: bankAccount, category: categories[1], amount: 200.00, transactionDate: .now, createdAt: .now, updatedAt: .now),
            Transaction(id: 3, account: bankAccount, category: categories[2], amount: 100.00, transactionDate: .now.advanced(by: -1000), createdAt: .now, updatedAt: .now),
            Transaction(id: 4, account: bankAccount, category: categories[3], amount: 40000.00, transactionDate: .now.advanced(by: 60), createdAt: .now, updatedAt: .now),
        ]
    }
    
    func transactions(period: ClosedRange<Date>) async throws -> [Transaction] {
        transactions.filter { transaction in
            period.contains(transaction.transactionDate)
        }
    }
    
    func transactions(startDate: Date, endDate: Date) async throws -> [Transaction] {
        transactions.filter {
            $0.transactionDate >= startDate && $0.transactionDate <= endDate
        }
    }
    
    func createTransaction(id: Int, account: BankAccountBrief, category: Category, amount: Decimal, transactionDate: Date, comment: String? = nil) async throws {
        let transaction = Transaction(id: id, account: account, category: category, amount: amount, transactionDate: transactionDate, comment: comment,  createdAt: .now, updatedAt: .now)
        transactions.append(transaction)
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        if let position = transactions.firstIndex(where: {$0.id == transaction.id}) {
            transactions[position] = transaction
            transactions[position].updatedAt = .now
        } else {
            throw TransactionServiceError.transactionNotFound
        }
        
    }
    
    func deleteTransaction(id: Int) async throws {
        if let position = transactions.firstIndex(where: {$0.id == id}) {
            transactions.remove(at: position)
        } else {
            throw TransactionServiceError.transactionNotFound
        }
    }
    
    enum TransactionServiceError: Error {
        case transactionNotFound
    }
}
