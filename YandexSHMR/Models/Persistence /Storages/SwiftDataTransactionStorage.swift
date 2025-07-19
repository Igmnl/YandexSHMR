//
//  SwiftDataTransactionStorage.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.07.2025.
//

import Foundation
import SwiftData

enum TransactionServiceError: Error {
    case accountNotFound
}

final class SwiftDataTransactionStorage: TransactionStorage {
    private let modelContainer: ModelContainer
    private let context: ModelContext
    
    init() {
        do {
            let schema = Schema([
                TransactionModel.self
            ])
            
            let config = ModelConfiguration(
                "TransactionsDB",
                schema: schema,
                isStoredInMemoryOnly: false,
                allowsSave: true
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: config
            )
            
            context = ModelContext(modelContainer)
            
            try verifyStoreAvailability()
        } catch {
            fatalError("Failed to initialize storage: \(error)")
        }
    }
    
    private func verifyStoreAvailability() throws {
        let descriptor = FetchDescriptor<TransactionModel>()
        _ = try context.fetch(descriptor)
    }
    
    func getTransaction(id: Int) async throws -> TransactionResponse {
        guard let model = try getModel(by: id) else {
            throw TransactionService.TransactionServiceError.transactionNotFound
        }
        
        let responses = try await convertToResponses(models: [model])
        guard let response = responses.first else {
            throw TransactionService.TransactionServiceError.transactionNotFound
        }
        
        return response
    }
    
    func getAllTransactions() async throws -> [TransactionResponse] {
        let descriptor = FetchDescriptor<TransactionModel>(sortBy: [SortDescriptor(\.createdAt)])
        let models = try context.fetch(descriptor)
        
        let account = try await BankAccountService().bankAccount()
        let accountB = BankAccountBrief(id: account.id, name: account.name, balance: account.balance, currency: account.currency)
        let categories = try await CategoriesService().categories()
        
        return models.compactMap { model in
            return model.toResponse(account: accountB, category: categories.first(where: {$0.id == model.categoryId}) ?? Category(id: 123123123, name: "ОШИБКА", emoji: "О", isIncome: false))
        }
    }
    
    func getTransactions(for accountId: Int, startDate: Date, endDate: Date) async throws -> [TransactionResponse] {
        let predicate = #Predicate<TransactionModel> {
            $0.accountId == accountId &&
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
        
        let descriptor = FetchDescriptor<TransactionModel>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.transactionDate, order: .reverse)]
        )
        
        let models = try context.fetch(descriptor)
        print("Загружено \(models.count) моделей из локального хранилища")
        
        guard let account = try? await BankAccountService().bankAccount() else {
            print("Ошибка: не удалось загрузить данные счета")
            return []
        }
        
        let categories = try await CategoriesService().categories()
        let accountBrief = BankAccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
        
        return models.compactMap { model in
            guard let category = categories.first(where: { $0.id == model.categoryId }) else {
                print("Предупреждение: не найдена категория для транзакции \(model.id)")
                return nil
            }
            
            return TransactionResponse(
                id: model.id,
                account: accountBrief,
                category: category,
                amount: model.amount,
                transactionDate: model.transactionDate,
                comment: model.comment,
                createdAt: model.createdAt,
                updatedAt: model.updatedAt
            )
        }
    }
    
    func updateTransaction(_ transaction: TransactionResponse) async throws {
        let predicate = #Predicate<TransactionModel> { $0.id == transaction.id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try context.fetch(descriptor).first {
            existing.amount = transaction.amount
            existing.comment = transaction.comment ?? ""
            existing.transactionDate = transaction.transactionDate
            existing.categoryId = transaction.category.id
            existing.accountId = transaction.account.id
        } else {
            throw TransactionService.TransactionServiceError.transactionNotFound
        }
    }
    
    func deleteTransaction(id: Int) async throws {
        let predicate = #Predicate<TransactionModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existing = try context.fetch(descriptor).first {
            context.delete(existing)
        } else {
            throw TransactionService.TransactionServiceError.transactionNotFound
        }
    }
    
    func createTransaction(_ transaction: TransactionResponse) async throws {
        let model = TransactionModel(
            id: transaction.id,
            accountId: transaction.account.id,
            categoryId: transaction.category.id,
            amount: transaction.amount,
            transactionDate: transaction.transactionDate,
            comment: transaction.comment ?? "",
            createdAt: transaction.createdAt,
            updatedAt: transaction.updatedAt
        )
        context.insert(model)
    }
    
    func saveTransactions(_ remoteTransactions: [TransactionResponse], forPeriod startDate: Date, endDate: Date) async throws {
        let remoteIdsInPeriod = Set(remoteTransactions.map { $0.id })
        
        let localModelsInPeriod = try await getLocalModels(for: startDate, endDate: endDate)
        
        for model in localModelsInPeriod {
            if !remoteIdsInPeriod.contains(model.id) {
                context.delete(model)
                print("Удалена локальная транзакция \(model.id) за период \(startDate)-\(endDate)")
            }
        }
        
        for transaction in remoteTransactions {
            if let existing = try?  getModel(by: transaction.id) {
                existing.update(from: transaction)
            } else {
                context.insert(
                    TransactionModel(
                        id: transaction.id,
                        accountId: transaction.account.id,
                        categoryId: transaction.category.id,
                        amount: transaction.amount,
                        transactionDate: transaction.transactionDate,
                        comment: transaction.comment ?? "",
                        createdAt: transaction.createdAt,
                        updatedAt: transaction.updatedAt
                    )
                )
            }
        }
        
        try context.save()
    }
    
    private func getModel(by id: Int) throws -> TransactionModel? {
        let predicate = #Predicate<TransactionModel> { $0.id == id }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor).first
    }
    
    private func getLocalModels(for startDate: Date, endDate: Date) async throws -> [TransactionModel] {
        let predicate = #Predicate<TransactionModel> {
            $0.transactionDate >= startDate &&
            $0.transactionDate <= endDate
        }
        let descriptor = FetchDescriptor(predicate: predicate)
        return try context.fetch(descriptor)
    }
    
    private func convertToResponses(models: [TransactionModel]) async throws -> [TransactionResponse] {
        let categories = try await CategoriesService().categories()
        let account = try await BankAccountService().bankAccount()
        let accountBrief = BankAccountBrief(
            id: account.id,
            name: account.name,
            balance: account.balance,
            currency: account.currency
        )
        
        return models.compactMap { model in
            guard let category = categories.first(where: { $0.id == model.categoryId }) else {
                return nil
            }
            
            return TransactionResponse(
                id: model.id,
                account: accountBrief,
                category: category,
                amount: model.amount,
                transactionDate: model.transactionDate,
                comment: model.comment,
                createdAt: model.createdAt,
                updatedAt: model.updatedAt
            )
        }
    }
}
