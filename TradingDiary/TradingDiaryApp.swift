//
//  TradingDiaryApp.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

@main
struct TradingDiaryApp: App {
    
    @StateObject private var themeManager: ThemeManager
    @StateObject private var tradeViewModel: TradeViewModel
    @StateObject private var authViewModel: AuthViewModel
    @StateObject private var marketViewModel: MarketViewModel

    private let container: AppContainer

    init() {
        let container = AppContainer()
        self.container = container

        _themeManager = StateObject(wrappedValue: ThemeManager())
        _tradeViewModel = StateObject(
            wrappedValue: TradeViewModel(
                fetchTrades: container.fetchTradesUseCase,
                addTrade: container.addTradeUseCase
            )
        )
        _authViewModel = StateObject(
            wrappedValue: AuthViewModel(
                loginUseCase: container.loginUseCase,
                logoutUseCase: container.logoutUseCase,
                getAuthState: container.getAuthStateUseCase
            )
        )
        _marketViewModel = StateObject(
            wrappedValue: MarketViewModel(fetchMarketPrices: container.fetchMarketPricesUseCase)
        )
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    MainTabView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(tradeViewModel)
            .environmentObject(themeManager)
            .environmentObject(authViewModel)
            .environmentObject(marketViewModel)
            .preferredColorScheme(themeManager.colorScheme)
        }
    }
}
