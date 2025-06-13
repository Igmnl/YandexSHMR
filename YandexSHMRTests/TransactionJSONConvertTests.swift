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
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 1,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:50.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = Transaction.parse(jsonObject: json)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        
        XCTAssertNotNil(transaction)
        XCTAssertEqual(transaction?.id, 1)
        XCTAssertEqual(transaction?.accountId, 1)
        XCTAssertEqual(transaction?.categoryId, 1)
        XCTAssertEqual(transaction?.amount, 500)
        XCTAssertEqual(transaction?.transactionDate, dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
        XCTAssertEqual(transaction?.comment, "Зарплата за месяц")
        XCTAssertEqual(transaction?.createdAt, dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
        XCTAssertEqual(transaction?.updatedAt, dateFormatter.date(from: "2025-06-13T20:14:50.023Z"))
    }
    
    func testNilCommentJSON() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 1,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:50.023Z",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNotNil(transaction)
        XCTAssertNil(transaction?.comment)
    }
    
    func testInvalidDate() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "categoryId": 1,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:500.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testInvalidJSONProperty() {
        let json: [String: Any] = [
            "id": "АРБУЗ",
            "accountId": 1,
            "categoryId": 1,
            "amount": "500.00",
            "transactionDate": "2025-06-13T20:14:500.023Z",
            "comment": "Зарплата за месяц",
            "createdAt": "2025-06-13T20:14:50.023Z",
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testInvalidJSONFormat() {
        let json: [String: Any] = [
            "id": 1,
            "accountId": 1,
            "updatedAt": "2025-06-13T20:14:50.023Z"
        ]
        
        let transaction = Transaction.parse(jsonObject: json)
        XCTAssertNil(transaction)
    }
    
    func testValidTransaction() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        let testDate = dateFormatter.date(from: "2025-06-13T20:14:50.023Z")!
        
        let transaction = Transaction(id: 1, accountId: 1, categoryId: 1, amount: 500.00, transactionDate: testDate,comment: "Зарплата за месяц", createdAt: testDate, updatedAt: testDate)
        let json = transaction.jsonObject
        
        XCTAssertNotNil(json)
        
        let parsedTransaction = Transaction.parse(jsonObject: json)
        
        XCTAssertEqual(parsedTransaction?.id, transaction.id)
        XCTAssertEqual(parsedTransaction?.accountId, transaction.accountId)
        XCTAssertEqual(parsedTransaction?.categoryId, transaction.categoryId)
        XCTAssertEqual(parsedTransaction?.amount, transaction.amount)
        XCTAssertEqual(parsedTransaction?.transactionDate, transaction.transactionDate)
        XCTAssertEqual(parsedTransaction?.comment, transaction.comment)
        XCTAssertEqual(parsedTransaction?.createdAt, transaction.createdAt)
        XCTAssertEqual(parsedTransaction?.updatedAt, transaction.updatedAt)
    }
    
    func testNilCommentTransaction() {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.sss'Z'"
        let testDate = dateFormatter.date(from: "2025-06-13T20:14:50.023Z")!
        
        let transaction = Transaction(id: 1, accountId: 1, categoryId: 1, amount: 500.00, transactionDate: testDate, createdAt: testDate, updatedAt: testDate)
        let json = transaction.jsonObject
        
        XCTAssertNotNil(json)
        
        let parsedTransaction = Transaction.parse(jsonObject: json)
        
        XCTAssertNotNil(parsedTransaction)
        XCTAssertEqual(parsedTransaction?.comment, transaction.comment)
    }
    
}
