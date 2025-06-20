//
//  TransactionsListView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct TransactionsListView: View {
    @State private var transactions: [Transaction] = []
    @State private var isLoading = false
    let direction: Direction
    
    private var sumOfTransactions: Decimal {
        var sum: Decimal = 0
        
        for transaction in transactions {
            sum += transaction.amount
        }
        return sum
    }
    private var currencyCode: String {
        transactions.first?.account.currency ?? "RUB"
    }
    
    var body: some View {
        List {
            HStack {
                Text("Всего: ")
                Spacer()
                Text(sumOfTransactions,
                     format:
                        .currency(code: currencyCode)
                        .presentation(.narrow)
                        .precision(.fractionLength(0...2))
                )
            }
            
            Section("Операции") {
                ForEach(transactions) { transaction in
                    if transaction.category.direction == direction {
                        NavigationLink{
                            Text("\(transaction.amount)")
                        } label: {
                            TransactionItemView(transaction: transaction)
                        }
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: MyHistoryView(direction: direction)) {
                    Image(systemName:"clock")
                        .accessibilityLabel(Text("История"))
                }
            }
        }
        .task {
           await fetchTransactions()
        }
    }
    
    func fetchTransactions() async {
        isLoading = true
        
        let calendar = Calendar.current
        let now = Date()
        
        let dayStart = calendar.startOfDay(for: now)
        let dayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? .now
        
        do {
            transactions = try await TransactionService().transactions(startDate: dayStart, endDate: dayEnd)
            transactions = transactions.filter({ $0.category.direction == direction })
        } catch {
            print("Ошибка загрузки транзакций: \(error)")
        }
        
        isLoading = false
    }
}

#Preview {
    TransactionsListView(direction: .outcome)
}
