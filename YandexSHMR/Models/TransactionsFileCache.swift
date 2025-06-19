//
//  TransactionsFileCache.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 13.06.2025.
//

import Foundation

struct TransactionsFileCache {
    
    private(set) var transactions: [Transaction] = []
    
    mutating func add(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    mutating func delete(id: Int) throws {
        if let position = transactions.firstIndex(where: { $0.id == id }) {
            transactions.remove(at: position)
        } else {
            throw TransactionsFileCacheError.transactionNotFound
        }
    }
    
    func saveToJSONFile(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path()) else {
            throw TransactionsFileCacheError.fileNotFound
        }
        
        let jsonObjects = transactions.map { transaction in
            transaction.jsonObject
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObjects)
        
        try jsonData.write(to: url)
    }
    
    func loadFromJSONFile(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path()) else {
            throw TransactionsFileCacheError.fileNotFound
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw TransactionsFileCacheError.loadFailed
        }
        
        
        guard let jsonObjects = try JSONSerialization.jsonObject(with: data, options: []) as? [Any] else {
            throw TransactionsFileCacheError.invalidFormat
        }
        
        let transactions = jsonObjects.compactMap { jsonObject in
            if let transaction = Transaction.parse(jsonObject: jsonObject) {
                if !isContains(transaction: transaction) {
                    return transaction
                }
            }
            return nil
        }
    }
    
    private func isContains(transaction: Transaction) -> Bool {
        if transactions.contains(where: { transaction.id == $0.id }) {
            return true
        }
        return false
    }
    
    private enum TransactionsFileCacheError: Error {
        case invalidFormat
        case loadFailed
        case fileNotFound
        case transactionNotFound
    }
}
