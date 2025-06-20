//
//  TabBar.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 19.06.2025.
//

import SwiftUI

struct TabBar: View {
    
    var body: some View {
        TabView {
            Tab("Расходы", image: "downtrend-7-2") {
                
                ExpensesView()
            }
            
            Tab("Доходы", image: "uptrend-7") {
                IncomeView()
            }
            
            Tab("Счет", image: "calculator-7") {
                BankAccountView()
            }
            
            Tab("Статьи", image: "bar-chart-side-7") {
                ArticlesView()
            }
            
            Tab("Настройки", image: "Vector") {
                SettingsView()
            }
        }
    }
}


#Preview {
    TabBar()
}
