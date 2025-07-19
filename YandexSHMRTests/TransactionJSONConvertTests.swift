//
//  YandexSHMRTests.swift
//  YandexSHMRTests
//
//  Created by Никита Арабчик on 13.06.2025.
//

import XCTest
@testable import YandexSHMR

final class TransactionJSONConvertTests: XCTestCase {
    
    func testValidJSON() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        
        let json: [String: Any] = [
            "id": 1,
            "account": account,
            "category": category,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:50.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = TransactionResponse.parse(jsonObject: json)

        
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.account, account)
        XCTAssertEqual(transaction?.category, category)
        XCTAssertEqual(transaction?.amount, 500)
        XCTAssertEqual(transaction?.transactionDate, TransactionResponse.dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
        XCTAssertEqual(transaction?.comment, "Зарплата за месяц")
        XCTAssertEqual(transaction?.createdAt, TransactionResponse.dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
        XCTAssertEqual(transaction?.updatedAt, TransactionResponse.dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
    }
    
    func testNilCommentJSON() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        
        let json: [String: Any] = [
            "id": 1,
            "account": account,
            "category": category,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:50.023Z",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = TransactionResponse.parse(jsonObject: json)
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment)
    }
    
    func testInvalidDate() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        
        let json: [String: Any] = [
            "id": 1,
            "accountId": account,
            "categoryId": category,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:500.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = TransactionResponse.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testInvalidJSONProperty() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        
        let json: [String: Any] = [
            "id": "АРБУЗ",
            "accountId": account,
            "categoryId": category,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:500.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = TransactionResponse.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testInvalidJSONFormat() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        
        let transaction = TransactionResponse.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testValidTransaction() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        let testDate = TransactionResponse.dateFormatter.date(from: "2025-06-13T20:14:50.023Z")!
        
        let transaction = TransactionResponse(id: 1, account: account, category: category, amount: 500.00, transactionDate: testDate,comment: "Зарплата за месяц", createdAt: testDate, updatedAt: testDate)
        let json = transaction.jsonObject
        
        XCTAssertNotNil(json)
        
        let parsedTransaction = TransactionResponse.parse(jsonObject: json)
        
        XCTAssertEqual(parsedTransaction?.id, transaction.id)
        XCTAssertEqual(parsedTransaction?.account, transaction.account)
        XCTAssertEqual(parsedTransaction?.category, transaction.category)
        XCTAssertEqual(parsedTransaction?.amount, transaction.amount)
        XCTAssertEqual(parsedTransaction?.transactionDate, transaction.transactionDate)
        XCTAssertEqual(parsedTransaction?.comment, transaction.comment)
        XCTAssertEqual(parsedTransaction?.createdAt, transaction.createdAt)
        XCTAssertEqual(parsedTransaction?.updatedAt, transaction.updatedAt)
    }
    
    func testNilCommentTransaction() {
        let account = BankAccountBrief(id: 1, name: "Основной счёт", balance: 1000.00, currency: "RUB")
        let category = Category(id: 1, name: "Зарплата", emoji: "💰", isIncome: true)
        let testDate = TransactionResponse.dateFormatter.date(from: "2025-06-13T20:14:50.023Z")!
        
        let transaction = TransactionResponse(id: 1, account: account, category: category, amount: 500.00, transactionDate: testDate, createdAt: testDate, updatedAt: testDate)
        let json = transaction.jsonObject
        
        XCTAssertNotNil(json)
        
        let parsedTransaction = TransactionResponse.parse(jsonObject: json)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.comment, transaction.comment)
    }
    
}
