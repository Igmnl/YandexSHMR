//
//  HistoryAndAnalyzeView.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 12.07.2025.
//

import SwiftUI

struct HistoryAndAnalyzeView: View {
    let direction: Direction
    let service: TransactionService
    
    @State private var selectedTransaction: TransactionResponse?
    @StateObject private var coordinator = AnalyzeCoordinator()
    
    var body: some View {
        NavigationStack {
            AnalyzeView(direction: direction, service: service, coordinator: coordinator)
                .navigationTitle("Анализ")
                .edgesIgnoringSafeArea(.all)
                .onReceive(coordinator.$selectedTransaction) { transaction in
                    selectedTransaction = transaction
                }
                .fullScreenCover(item: $selectedTransaction) { transaction in
                    TransactionEditView(transaction: transaction, service: service)
                        .onDisappear {
                            selectedTransaction = nil
                        }
                }
        }
    }
}

class AnalyzeCoordinator: ObservableObject {
    @Published var selectedTransaction: TransactionResponse? {
        didSet {
            if selectedTransaction == nil {
            }
        }
    }
}



#Preview {
    HistoryAndAnalyzeView(direction: .income, service: TransactionService())
}
