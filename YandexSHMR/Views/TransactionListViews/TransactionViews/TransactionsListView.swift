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
    @State private var selectedTransaction: Transaction?
    @State private var addTransaction = false
    var service = TransactionService()
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
                        Button {
                            self.selectedTransaction = transaction
                        } label: {
                            TransactionItemView(transaction: transaction)
                        }
                        .tint(.primary)
                    }
                }
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button() {
                addTransaction.toggle()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 56, height: 56)
            }
            .padding(.trailing, 16)
            .padding(.bottom, 20)
            .accessibilityLabel("Добавить транзакцию")
            .tint(.accent)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: MyHistoryView(service: service, direction: direction)) {
                    Image(systemName:"clock")
                        .accessibilityLabel(Text("История"))
                }
            }
        }
        .task {
           await fetchTransactions()
        }
        .fullScreenCover(isPresented: $addTransaction) {
            TransactionCreateView(service: service, direction: direction)
                .onDisappear {
                    Task {
                        await fetchTransactions()
                    }
                }
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction: transaction, service: service)
                .onDisappear {
                    Task {
                        await fetchTransactions()
                    }
                }
        }
    }
    
    func fetchTransactions() async {
        isLoading = true
        
        let calendar = Calendar.current
        let now = Date()
        
        let dayStart = calendar.startOfDay(for: now)
        let dayEnd = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: now) ?? .now
        
        do {
            transactions = try await service.transactions(startDate: dayStart, endDate: dayEnd)
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
