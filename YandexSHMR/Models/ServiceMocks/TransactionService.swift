//
//  TransactionService.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation


final class TransactionService {
    func transactions(accountId: Int, startDate: Date, endDate: Date) async throws -> [Transaction] {
        let dateFormatter =  ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        let startDate = dateFormatter.string(from: startDate)
        let endDate = dateFormatter.string(from: endDate)
        return try await NetworkClient.shared.requets(method: .get, path: "/transactions/account/\(accountId)/period?startDate=\(startDate)&endDate=\(endDate)")
    }
    
    func createTransaction(transaction: Transaction) async throws {
        let formatedDate = Transaction.dateFormatter.string(from: transaction.transactionDate)
        let newTransaction = TransactionRequest(accountId: transaction.account.id, categoryId: transaction.category.id, amount: transaction.amount.description, transactionDate: formatedDate, comment: transaction.comment ?? "")
        let _: TransactionResponse = try await NetworkClient.shared.requets(method: .post, path: "/transactions", body: newTransaction)
    }
    
    func updateTransaction(transaction: Transaction) async throws {
        let formatedDate = Transaction.dateFormatter.string(from: transaction.transactionDate)
        let newTransaction = TransactionRequest(accountId: transaction.account.id, categoryId: transaction.category.id, amount: transaction.amount.description, transactionDate: formatedDate, comment: transaction.comment ?? "")
        let _: Transaction = try await NetworkClient.shared.requets(method: .put, path: "/transactions/\(transaction.id)", body: newTransaction)
    }
    
    func deleteTransaction(transactionId: Int) async throws {
        let _: DecodableStub = try await NetworkClient.shared.requets(
            method: .delete,
            path: "/transactions/\(transactionId)"
        )
    }
    
    enum TransactionServiceError: Error {
        case transactionNotFound
        case deletionFailed(reason: String)
    }
    
}
struct DecodableStub: Decodable {}
