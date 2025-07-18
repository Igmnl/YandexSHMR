//
//  MyHistoryView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct MyHistoryView: View {
    @State private var selectedStartDate = Calendar.current.date(byAdding: .month, value: -1, to: .now) ?? .now
    @State private var selectedEndDate = Date()
    @State private var sortSelector = TransactionSortOrder.amountDescending
    @State private var transactions: [Transaction] = []
    @State private var selectedTransaction: Transaction?
    @State private var loadingState = LoadingState.loading
    @State private var showAlert = false
    @State private var alertError = ""
    var service: TransactionService
    
    let direction: Direction
    
    private var sortedTransactions: [Transaction] {
        transactions.sorted {
            switch sortSelector {
            case .dateDescending:
                return $0.transactionDate > $1.transactionDate
            case .dateAscending:
                return $0.transactionDate < $1.transactionDate
            case .amountDescending:
                return $0.amount > $1.amount
            case .amountAscending:
                return $0.amount < $1.amount
            }
        }
    }
    var transactionsSum: Decimal {
        var sum: Decimal = 0
        for transaction in sortedTransactions {
            sum += transaction.amount
        }
        return sum
    }
    var currencyCode: String {
        transactions.first?.account.currency ?? "RUB"
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Начало")
                    Spacer()
                    DatePicker("Дата начала", selection: $selectedStartDate, in: ...Date(), displayedComponents: [.date])
                        .tint(.accent)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.transactionIconBackground))
                        .labelsHidden()
                        .onChange(of: selectedStartDate) { oldValue, newValue in
                            if newValue > selectedEndDate {
                                selectedEndDate = newValue
                            }
                            Task {
                                await fetchTransactions()
                            }
                        }
                }
                
                HStack {
                    Text("Конец")
                    Spacer()
                    DatePicker("Дата конца", selection: $selectedEndDate, in: ...Date(), displayedComponents: [.date])
                        .tint(.accent)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.transactionIconBackground))
                        .labelsHidden()
                        .onChange(of: selectedEndDate) { oldValue, newValue in
                            if newValue < selectedStartDate {
                                selectedStartDate = newValue
                            }
                            Task {
                                await fetchTransactions()
                            }
                        }
                }
                
                HStack {
                    Text("Сортировка")
                    Spacer()
                    Picker("Выбор сортировки", selection: $sortSelector) {
                        ForEach(TransactionSortOrder.allCases, id: \.self) { sortOrder in
                            Text(sortOrder.rawValue)
                                .tag(sortOrder)
                        }
                    }
                    .tint(.secondary)
                    .labelsHidden()
                }
                
                HStack {
                    Text("Сумма")
                    Spacer()
                    Text(transactionsSum, format:
                            .currency(code: currencyCode)
                            .presentation(.narrow)
                            .precision(.fractionLength(0...2)))
                }
                
            }
            
            Section("Операции") {
                ForEach(sortedTransactions) { transaction in
                    Button {
                        selectedTransaction = transaction
                    } label: {
                        MyHistoryListItemView(transaction: transaction)
                    }
                    .tint(.primary)
                }
            }
        }
        .navigationTitle("Моя история")
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    HistoryAndAnalyzeView(direction: direction, service: service)
                } label: {
                    Image(systemName: "document")
                }
            }
        }
        .overlay {
            if loadingState == .loading {
                ProgressView()
            }
        }
        .task {
            await fetchTransactions()
        }
        .fullScreenCover(item: $selectedTransaction) { transaction in
            TransactionEditView(transaction: transaction, service: service)
                .onDisappear {
                    Task {
                        await fetchTransactions()
                    }
                }
        }
        .alert("Ошибка!", isPresented: $showAlert) {} message: {
            Text(alertError)
        }
    }
    
    func fetchTransactions() async {
        loadingState = .loading
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: selectedStartDate)
        let endDate = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: selectedEndDate) ?? .now
        do {
            let account = try await BankAccountService().bankAccount()
            transactions = try await service.transactions(accountId: account.id, startDate: startDate, endDate: endDate)
            transactions = transactions.filter({ $0.category.direction == direction })
            loadingState = .loaded
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Error loading transactions in history: \(error.localizedDescription)")
        }
    }
}

enum TransactionSortOrder: String, CaseIterable {
    case dateAscending = "Сначала старые"
    case dateDescending = "Сначала новые"
    case amountAscending = "По возрастанию"
    case amountDescending = "По убыванию"
}

#Preview {
    MyHistoryView(service: TransactionService(), direction: .income)
}
