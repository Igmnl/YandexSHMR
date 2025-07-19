//
//  TransactionEditView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 11.07.2025.
//

import SwiftUI

struct TransactionCreateView: View {
    @Environment(\.dismiss) var dismiss
    @State private var transaction: TransactionResponse
    @State private var categories: [Category] = []
    @State private var isValid = false
    @FocusState private var isFocused: Bool
    @State private var loadingState = LoadingState.loading
    @State private var showAlert = false
    @State private var alertError = ""
    private var maxLength = 30
    var service: TransactionService
    
    var body: some View {
        NavigationStack {
            List {
                Picker("Статья", selection: $transaction.category) {
                    ForEach(categories) { category in
                        Text(category.name)
                            .tag(category)
                    }
                }
                .tint(.secondary)
                
                HStack {
                    Text("Cумма")
                    
                    TextField("Сумма", value: $transaction.amount, format: .currency(code: transaction.account.currency)
                        .presentation(.narrow)
                        .precision(.fractionLength(0...2))
                    )
                    .onChange(of: transaction.amount) {newValue, oldValue in
                        if newValue > Decimal(100_000_000_000_000_000) {
                            transaction.amount = Decimal(100_000_000_000_000_000)
                        }
                    }
                    .focused($isFocused)
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.decimalPad)
                    .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Дата")
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    DatePicker("Дата", selection: $transaction.transactionDate, in: ...Date(), displayedComponents: .date)
                        .labelsHidden()
                        .background(.accent.opacity(0.33))
                        .clipShape(.rect(cornerRadius: 8))
                        .tint(.accent)
                }
                HStack {
                    Text("Время")
                        .accessibilityHidden(true)
                    
                    Spacer()
                    
                    DatePicker("Время", selection: $transaction.transactionDate, in: ...Date(), displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .background(.accent.opacity(0.33))
                        .clipShape(.rect(cornerRadius: 8))
                        .tint(.accent)
                }
                
                TextField(
                    "Коментарий",
                    text: $transaction.comment.toUnwrapped(defaultValue: ""),
                    axis: .vertical)
                .onChange(of: transaction.comment ?? "") { newValue, oldValue in
                    if newValue.count > maxLength {
                        transaction.comment = String(newValue.prefix(maxLength))
                    }
                }
                .focused($isFocused)
                
            }
            .navigationTitle("Мои \(transaction.category.direction == .income ? "доходы" : "расходы")")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Создать") {
                        if transaction.amount <= 0 || transaction.category.name == "" {
                            isValid.toggle()
                        } else {
                            Task {
                                await createTransaction()
                            }
                        }
                    }
                }
            }
            .tint(.toolbarButton)
            .task {
                await loadInitialData()
            }
            .alert("Заполните все поля", isPresented: $isValid) {
                Button("Готово") {}
            }
            .alert("Ошибка!", isPresented: $showAlert) {} message: {
                Text(alertError)
            }
        }
    }
    
    private func loadInitialData() async {
        do {
            let bankAccount = try await BankAccountService().bankAccount()
            let bankAccountBrief = BankAccountBrief(id: bankAccount.id, name: bankAccount.name, balance: bankAccount.balance, currency: bankAccount.currency)
            let categories = try await CategoriesService().categories(for: transaction.category.direction)
            
            self.categories = categories
            self.transaction = TransactionResponse(id: 0, account: bankAccountBrief, category: categories.first ?? Category(id: 0, name: "", emoji: "N", isIncome: transaction.category.isIncome), amount: 0, transactionDate: .now, createdAt: .now, updatedAt: .now)
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Error initialization: \(error.localizedDescription)")
        }
    }
    
    private func createTransaction() async {
        loadingState = .loading
        do {
            let bankAccount = try await BankAccountService().bankAccount()
            
            let bankAccountBrief  = BankAccountBrief(id: bankAccount.id, name: bankAccount.name, balance: bankAccount.balance, currency: bankAccount.currency)
            let transaction = TransactionResponse(id: 1, account: bankAccountBrief, category: transaction.category, amount: transaction.amount, transactionDate: transaction.transactionDate, createdAt: Date(), updatedAt: Date())
            
            try await service.createTransaction(transaction: transaction)
            loadingState = .loaded
            dismiss()
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Saving transaction error: \(error.localizedDescription)")
        }
    }
    
    init(service: TransactionService, direction: Direction) {
        self.service = service
        let placeholderAccount = BankAccountBrief(id: 0, name: "", balance: 0, currency: "RUB")
        let placeholderCategory = Category(id: 0, name: "", emoji: "N", isIncome: direction == .income)
        self._transaction = State(initialValue: TransactionResponse(id: 0, account: placeholderAccount, category: placeholderCategory, amount: 0, transactionDate: .now, createdAt: .now, updatedAt: .now))
    }
}

#Preview {
    TransactionCreateView(service: TransactionService(), direction: .income)
}
