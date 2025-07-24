//
//  BankAccountView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI
struct BankAccountView: View {
    @State private var loadingState: LoadingState = .loading
    @State private var bankAccount = BankAccount(id: 1, userId: 1, name: "", balance: 0, currency: "RUB", createdAt: Date(), updatedAt: Date())
    @State private var isEditing = false
    @State private var showAlert = false
    @State private var alertError = ""
    @State private var transactions: [TransactionResponse] = []
    var service: TransactionService
    
    let bankAccountService = BankAccountService()
    
    var body: some View {
        NavigationStack {
            Group {
                if isEditing {
                    BankAccountEditView(bankAccountService: bankAccountService, bankAccount: bankAccount, isEditing: $isEditing)
                        .onDisappear {
                            Task {
                                await fetchBankAccount()
                            }
                        }
                } else {
                    BankAccountMainView(transactions: transactions, bankAccount: bankAccount, isEditing: $isEditing)
                        .onAppear {
                            Task {
                                await fetchBankAccount()
                            }
                        }
                }
            }
            .navigationTitle("Мой счет")
            .refreshable {
                await fetchBankAccount()
            }
            .overlay {
                if loadingState == .loading {
                    ProgressView()
                }
            }
            .alert("Ошибка!", isPresented: $showAlert) {} message: {
                Text(alertError)
            }
        }
        .tint(.toolbarButton)
    }
    
    func fetchBankAccount() async {
        loadingState = .loading
        do {
            bankAccount = try await bankAccountService.bankAccount()
            transactions = try await service.transactions(accountId: bankAccount.id, startDate: Calendar.current.date(byAdding: .month, value: -1, to: Date())!, endDate: Date())
            sleep(1)
            loadingState = .loaded
        } catch {
            loadingState = .error
            alertError = error.localizedDescription
            showAlert = true
            print("Error loading bankAccount: \(error.localizedDescription)")
        }
    }
}

