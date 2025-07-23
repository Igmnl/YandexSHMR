//
//  TransactionEditView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 11.07.2025.
//

import SwiftUI

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct TransactionEditView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isValid = false
    @State private var transaction: TransactionResponse
    @State private var categories: [Category] = []
    @State private var loadingState = LoadingState.loading
    @State private var showAlert = false
    @State private var alertError = ""
    @FocusState private var isFocused: Bool
    private var maxLength = 30
    var service: TransactionService
    
    var body: some View {
        NavigationStack {
            List {
                Section {
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
                        .onChange(of: transaction.amount) { newValue, oldValue in
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
                
                Section {
                    Button("Удалить \(transaction.category.isIncome ? "Доход" : "Расход")", role: .destructive) {
                        Task {
                            await deleteTransaction()
                        }
                    }
                }
                
            }
            .navigationTitle("Мои \(transaction.category.isIncome ? "Доходы" : "Расходы")")
            .overlay {
                if loadingState == .loading {
                    ProgressView()
                }
            }
            .task {
                await fetchCategories()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отменить") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Сохранить") {
                        if transaction.amount <= 0 || transaction.category.name.count == 0 {
                            isValid.toggle()
                        } else {
                            Task {
                                await saveTransaction()
                            }
                        }
                    }
                }
            }
            .tint(.toolbarButton)
            .alert("Неверный ввод данных", isPresented: $isValid) {
                Button("Готово") {}
            } message: {
                Text("Невалидные данные")
            }
            .alert("Ошибка!", isPresented: $showAlert) {} message: {
                Text(alertError)
            }
        }
    }
    
    init(transaction: TransactionResponse, service: TransactionService) {
        self.transaction = transaction
        self.service = service
    }
    
    func fetchCategories() async {
        loadingState = .loading
        do {
            categories = try await CategoriesService().categories(for: transaction.category.direction)
            loadingState = .loaded
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Error fetching categories: \(error.localizedDescription)")
        }
    }
    
    func saveTransaction() async {
        loadingState = .loading
        do {
            try await service.updateTransaction(transaction: transaction)
            loadingState = .loaded
            dismiss()
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Saving transaction error: \(error.localizedDescription)")
        }
    }
    
    func deleteTransaction() async {
        loadingState = .loading
        do {
            try await service.deleteTransaction(transactionId: transaction.id)
            loadingState = .loaded
            dismiss()
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Delete transaction error: \(error.localizedDescription)")
        }
    }
}
