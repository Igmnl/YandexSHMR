//
//  TransactionService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation


final class TransactionService {
    private var transactions: [Transaction] = []
    
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
    
    func createTransaction(id: Int, accountId: Int, categoryId: Int, amount: Decimal, transactionDate: Date, comment: String? = nil) async throws {
        let transaction = Transaction(id: id, accountId: accountId, categoryId: categoryId, amount: amount, transactionDate: transactionDate, comment: comment,  createdAt: .now, updatedAt: .now)
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
