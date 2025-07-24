//
//  IncomeView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct IncomeView: View {
    let service: TransactionService
    var body: some View {
        NavigationStack {
            TransactionsListView(service: service, direction: .income)
                .navigationTitle("Доходы сегодня")
        }
        .tint(.toolbarButton)
    }
}
