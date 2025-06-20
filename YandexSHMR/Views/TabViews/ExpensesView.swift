//
//  ExpensesView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct ExpensesView: View {

    var body: some View {
        NavigationStack {
            TransactionsListView(direction: .outcome)
                .navigationTitle("Расходы сегодня")
        }
        .tint(.toolbarButton)
    }
}

#Preview {
    ExpensesView()
}
