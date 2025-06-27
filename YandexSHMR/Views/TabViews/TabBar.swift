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
            Tab {
                ExpensesView()
            } label: {
                TabItemLabel(label: "Расходы", imageName: "downtrend-7")
            }
            
            Tab {
                IncomeView()
            } label: {
                TabItemLabel(label: "Доходы", imageName: "uptrend-7")
            }
            
            Tab {
                BankAccountView()
            } label: {
                TabItemLabel(label: "Счет", imageName: "calculator-7")
            }
            
            Tab {
                ArticlesView()
            } label: {
                TabItemLabel(label: "Статьи", imageName: "icons")
            }
            
            Tab {
                SettingsView()
            } label: {
                TabItemLabel(label: "Настройки", imageName: "Vector")
            }
        }
    }
}

struct TabItemLabel: View {
    var label: String
    var imageName: String
    
    var body: some View {
        Text(label)
        Image(imageName)
            .renderingMode(.template)
    }
}

#Preview {
    TabBar()
}
