//
//  BankAccountMainView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 27.06.2025.
//

import SwiftUI
import Charts


struct BankAccountMainView: View {
    var transactions: [TransactionResponse] = []
    let bankAccount: BankAccount
    @Binding var isEditing: Bool
    @State private var isBlur = false
    let startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    let endDate = Date()
    
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
                        .foregroundStyle(.primary)
                }
                .listRowBackground(Color.transactionIconBackground)
            }
            
            Chart {
                ForEach(0...30, id: \.self) { pos in
                    let today = Calendar.current.date(byAdding: .day, value: pos, to: startDate) ?? Date()
                    
                    let thisDayTransactionsSum = 1 + transactions.filter {$0.transactionDate == today}.reduce(0) { $0 + $1.amount }
                    
                    BarMark(
                        x: .value("Day", today, unit: .day),
                        y: .value("Transactions Summary", abs(thisDayTransactionsSum))
                    )
                    .foregroundStyle(thisDayTransactionsSum > 0 ? .accent : .red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .chartXAxis {
                AxisMarks(values: [
                    startDate,
                    Calendar.current.date(byAdding: .day, value: 15, to: startDate)!,
                    endDate
                ]) { value in
                    AxisValueLabel {
                        Text(value.as(Date.self)!.formatted(.dateTime.day().month(.twoDigits)))
                    }
                    .offset(x: value.index == 2 ? -35 : -10)
                }
            }
            .frame(width: 360, height: 233)
            .chartYAxis(.hidden)
            .listRowBackground(Color.clear)
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

