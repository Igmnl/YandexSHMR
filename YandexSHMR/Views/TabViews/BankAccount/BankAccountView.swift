//
//  BankAccountView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI
struct BankAccountView: View {
    @State private var loadingState: LoadingState = .loading
    @State private var bankAccount = BankAccount(id: 1, userId: 1, name: "", balance: 100, currency: "RUB", createdAt: Date(), updatedAt: Date())
    @State private var isEditing = false
    
    let bankAccountService = BankAccountService()
    
    var body: some View {
        NavigationStack {
            Group {
                if isEditing {
                    BankAccountEditView(bankAccountService: bankAccountService, bankAccount: bankAccount, isEditing: $isEditing)
                } else {
                    BankAccountMainView(bankAccount: bankAccount, isEditing: $isEditing)
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
        }
        .tint(.toolbarButton)
    }
    
    func fetchBankAccount() async {
        loadingState = .loading
        do {
            bankAccount = try await bankAccountService.bankAccount()
        } catch {
            print("error loading bank account: \(error)")
        }
        loadingState = .loaded
    }
    
    enum LoadingState {
        case loading
        case loaded
    }
}


#Preview {
    BankAccountView()
}
