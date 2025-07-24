//
//  MyHistoryItemView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI
import Foundation

struct MyHistoryListItemView: View {
    let transaction: TransactionResponse
    
    var body: some View {
        HStack {
            if !transaction.category.isIncome {
                Text("\(transaction.category.emoji)")
                    .font(.system(size: 14.5))
                    .padding(5)
                    .background(.transactionIconBackground)
                    .clipShape(.circle)
                    .padding(.trailing, 10)
            }
            VStack(alignment: .leading) {
                Text(transaction.category.name)
                    .font(.system(size: 17))
                
                if let comment = transaction.comment, !comment.isEmpty {
                    Text(comment)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 13))
                }
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(transaction.amount,
                     format:
                        .currency(code: transaction.account.currency)
                        .presentation(.narrow)
                        .precision(.fractionLength(0...2))
                )
                
                if transaction.transactionDate >= Calendar.current.startOfDay(for: .now) {
                    Text(transaction.formatedTransactionDate)
                        .font(.system(size: 17))
                }
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(height: 44)
    }
}
