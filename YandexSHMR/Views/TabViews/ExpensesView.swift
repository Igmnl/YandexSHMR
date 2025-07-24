//
//  ExpensesView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct ExpensesView: View {
    let service: TransactionService
    
    var body: some View {
        NavigationStack {
            TransactionsListView(service: service, direction: .outcome)
                .navigationTitle("Расходы сегодня")
        }
        .tint(.toolbarButton)
    }
}

