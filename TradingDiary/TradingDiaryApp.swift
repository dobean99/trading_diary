//
//  TradingDiaryApp.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

@main
struct TradingDiaryApp: App {
    
    @StateObject var vm = TradeViewModel()
    @StateObject var themeManager = ThemeManager()
    @StateObject var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(vm)
            .environmentObject(themeManager)
            .environmentObject(authViewModel)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
