//
//  BankAccountEditView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 27.06.2025.
//

import SwiftUI

struct BankAccountEditView: View {
    @State private var currency: String
    @State private var balance: Decimal
    
    @State private var showingConfirmationDialog = false
    @FocusState private var isFocused: Bool
    @Binding var isEditing: Bool
    
    var bankAccountService: BankAccountService
    
    var currencySymbol: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencyCode = currency
        return numberFormatter.currencySymbol
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("💰")
                        .padding(.trailing, 11)
                    Text("Баланс")
                    TextField("Баланс", value: $balance, format: .number)
                        .focused($isFocused)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .foregroundStyle(.secondary)
                }
                .onTapGesture {
                    isFocused = true
                }
            }
            
            Section {
                Button {
                    showingConfirmationDialog.toggle()
                } label: {
                    HStack {
                        Text("Валюта")
                        Spacer()
                        Text(currencySymbol)
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                }
                .tint(.primary)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 1, coordinateSpace: .global)
            .onEnded { _ in
                isFocused = false
            }
        )
        .confirmationDialog("Выберите валюту", isPresented: $showingConfirmationDialog) {
            Button("Российский рубль ₽") {
                currency = "RUB"
            }
            Button("Американский доллар $") {
                currency = "USD"
            }
            Button("Евро €") {
                currency = "EUR"
            }
        } message: {
            Text("Валюта")
                .tint(.black)
        }
        .toolbar {
            ToolbarItem {
                Button("Сохранить") {
                    Task {
                        await saveChanges()
                    }
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            }
        }
    }
    
    func saveChanges() async {
        do {
            try await bankAccountService.changeBankAccount(name: nil, balance: balance, currency: currency)
        } catch {
              print("Error saving changes, \(error)")
        }
    }
    
    init(bankAccountService: BankAccountService, bankAccount: BankAccount, isEditing: Binding<Bool>) {
        self.bankAccountService = bankAccountService
        self.currency = bankAccount.currency
        self.balance = bankAccount.balance
        
        _isEditing = isEditing
    }
}

#Preview {
    @Previewable @State var isEditing = false
    BankAccountEditView(bankAccountService: BankAccountService(), bankAccount: BankAccountService().account, isEditing: $isEditing)
}
