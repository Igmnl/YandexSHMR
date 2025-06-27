//
//  BankAccountMainView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 27.06.2025.
//

import SwiftUI

struct BankAccountMainView: View {
    let bankAccount: BankAccount
    @Binding var isEditing: Bool
    @State private var isBlur = false
    
    var currencySymbol: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.currencyCode = bankAccount.currency
        return numberFormatter.currencySymbol
    }
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("💰")
                        .padding(.trailing, 11)
                    Text("Баланс")
                    Spacer()
                    Text(bankAccount.balance, format:
                            .currency(code: bankAccount.currency)
                            .presentation(.narrow)
                            .precision(.fractionLength(0...2))
                    )
                    .spoiler(isOn: isBlur)
                    .onShake {
                        withAnimation {
                            isBlur.toggle()
                        }
                    }
                    .sensoryFeedback(.success, trigger: isBlur)
                    
                }
                .listRowBackground(Color.accent)
            }
            
            Section {
                HStack {
                    Text("Валюта")
                    Spacer()
                    Text(currencySymbol)
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Color.transactionIconBackground)
            }
        }
        .toolbar {
            ToolbarItem {
                Button("Редактировать") {
                    withAnimation {
                        isEditing.toggle()
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var isEditing: Bool = false
    BankAccountMainView(bankAccount: BankAccountService().account, isEditing: $isEditing)
}
