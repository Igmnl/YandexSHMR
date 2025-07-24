//
//  YandexSHMRApp.swift
//  YandexSHMR
//
//  Created by Никита Арабчик on 14.06.2025.
//

import SwiftUI
import LaunchAnimation

@main
struct YandexSHMRApp: App {
    @State private var showAnimation = true
    
    var body: some Scene {
        WindowGroup {
            if showAnimation {
                LaunchAnimationView {
                    withAnimation {
                        showAnimation = false
                    }
                }
                .ignoresSafeArea()
            } else {
                ContentView()
                    .transition(.identity)
                    .task {
                        await TransactionService().initialSync()
                    }
            }
        }
    }
}
