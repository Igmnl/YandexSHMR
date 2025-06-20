//
//  IncomeView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct IncomeView: View {

    var body: some View {
        NavigationStack {
            TransactionsListView(direction: .income)
                .navigationTitle("Доходы сегодня")
        }
        .tint(.toolbarButton)
    }
}

#Preview {
    IncomeView()
}
