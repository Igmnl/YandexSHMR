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
    @State private var statisticType = true
    @State private var selectedValue: (date: Date, amount: Decimal)?
    @State private var popoverPosition: CGPoint = .zero
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
            
            Section {
                Picker("Тип статистики", selection: $statisticType) {
                    Text("По дням")
                        .tag(true)
                    Text("По месяцам")
                        .tag(false)
                }
                .pickerStyle(.segmented)
                .listRowBackground(Color.clear)
            }
            
            
            Group {
                if statisticType{
                    dailyChart
                } else {
                    monthlyChart
                }
            }
            .listRowBackground(Color.clear)
            .chartYAxis(.hidden)
            .overlay(alignment: .top) {
                if let selectedValue  {
                    Text("\(selectedValue.date.formatted(date: .abbreviated, time: .omitted)): \(selectedValue.amount, format: .currency(code: bankAccount.currency))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
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
    
    private var monthlyChart: some View {
        let monthsToShow = 23
        let monthEnd = Calendar.current.startOfMonth(for: endDate)
        let monthStart = Calendar.current.date(byAdding: .month, value: -monthsToShow + 1, to: monthEnd)!
        
        return Chart {
            ForEach(0..<monthsToShow, id: \.self) { pos in
                let monthDate = Calendar.current.date(byAdding: .month, value: pos, to: monthStart)!
                let monthStart = Calendar.current.startOfMonth(for: monthDate)
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: monthStart)!
                let monthSum = calculateMonthlySum(from: monthDate, to: nextMonth)
                
                return BarMark(
                    x: .value("Месяц", monthDate, unit: .month),
                    y: .value("Сумма операций", abs(monthSum + 1))
                )
                .foregroundStyle(monthSum > 0 ? .accent : .red)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .annotation(position: .top) {
                    if let selectedDate = selectedValue?.date,
                       Calendar.current.isDate(selectedDate, equalTo: monthDate, toGranularity: .month) {
                        Text(monthSum, format: .currency(code: bankAccount.currency))
                            .font(.caption2)
                            .padding(4)
                            .background(Color.secondary.opacity(0.9))
                            .cornerRadius(4)
                            .shadow(radius: 2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month, count: 6)) { value in
                AxisValueLabel {
                    if let date = value.as(Date.self) {
                        Text(date.formatted(.dateTime.month(.abbreviated)))
                            .font(.caption)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                guard let date: Date = proxy.value(atX: location.x) else { return }
                                
                                let monthStart = Calendar.current.startOfMonth(for: date)
                                let monthEnd = Calendar.current.date(byAdding: .month, value: 1, to: monthStart)!
                                let sum = calculateMonthlySum(from: monthStart, to: monthEnd)
                                
                                withAnimation {
                                    selectedValue = (date: monthStart, amount: sum)
                                }
                            }
                            .onEnded { _ in
                                withAnimation {
                                    selectedValue = nil
                                }
                            }
                    )
            }
        }
        .frame(height: 240)
        .transition(.opacity.combined(with: .scale))
    }
    
    private var dailyChart: some View {
        Chart {
            ForEach(0...30, id: \.self) { pos in
                let today = Calendar.current.date(byAdding: .day, value: pos, to: startDate) ?? Date()
                let thisDayTransactionsSum = calculateDailySum(for: today)
                
                BarMark(
                    x: .value("День", today, unit: .day),
                    y: .value("Сумма транзакций", abs(thisDayTransactionsSum))
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
                .offset(x: value.index == 2 ? -30 : -10)
            }
        }
        .chartXScale(domain: Calendar.current.startOfDay(for: startDate)...Calendar.current.startOfDay(for: endDate).addingTimeInterval(86400))
        .frame(height: 233)
        .chartOverlay { proxy in
            GeometryReader { geometry in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let location = value.location
                                guard let date: Date = proxy.value(atX: location.x), date >= Calendar.current.startOfDay(for: startDate), date <= Calendar.current.startOfDay(for: endDate)  else { return }
                                
                                let dayStart = Calendar.current.startOfDay(for: date)
                                let sum = calculateDailySum(for: dayStart)
                                
                                withAnimation {
                                    selectedValue = (date: dayStart, amount: sum)
                                }
                            }
                            .onEnded { _ in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    selectedValue = nil
                                }
                            }
                    )
            }
        }
    }
    
    private func calculateDailySum(for date: Date) -> Decimal {
        let filteredTransactions = transactions.filter {
            Calendar.current.isDate($0.transactionDate, inSameDayAs: date)
        }
        return filteredTransactions.reduce(Decimal(0)) {
            if $1.category.isIncome {
                $0 + $1.amount
            } else {
                $0 + $1.amount * -1
            }
        }
    }
    
    private func calculateMonthlySum(from startDate: Date, to endDate: Date) -> Decimal {
        let filteredTransactions = transactions.filter {
            $0.transactionDate >= startDate && $0.transactionDate < endDate
        }
        return filteredTransactions.reduce(Decimal(0)) {
            if $1.category.isIncome {
                $0 + $1.amount
            } else {
                $0 + $1.amount * -1
            }
        }
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
}
