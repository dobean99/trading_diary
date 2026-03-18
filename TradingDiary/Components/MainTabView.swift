//
//  MainTabView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var showMenu = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            Color(.systemBackground)
                .ignoresSafeArea()
            SideMenuView()
                
            TabView{
                NavigationStack {
                    DashboardView(showMenu: $showMenu)
                }
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                NavigationStack {
                    TradeListView()
                }
                .tabItem {
                    Label("Trades", systemImage: "list.bullet")
                }
                
                NavigationStack {
                    AddTradeView()
                }
                .tabItem {
                    Label("Add", systemImage: "plus.circle.fill")
                }
                
                NavigationStack {
                    StatisticsView()
                }
                .tabItem {
                    Label("Stats", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
            .background(Color.clear)
            .offset(x: showMenu ? 260 : 0)
            //        .scaleEffect(showMenu ? 0.9 : 1)
            .cornerRadius(showMenu ? 20 : 0)
            .animation(.easeInOut(duration: 0.3), value: showMenu)
            .disabled(showMenu)
            .shadow(color: .black.opacity(showMenu ? 0.2 : 0), radius: 10)
        }
       
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 100 {
                        showMenu = true
                    }
                    
                    if value.translation.width < -100 {
                        showMenu = false
                    }
                }
        )
    }
    
}

#Preview {
    let container = AppContainer()
    return MainTabView()
        .environmentObject(
            TradeViewModel(
                fetchTrades: container.fetchTradesUseCase,
                addTrade: container.addTradeUseCase
            )
        )
        .environmentObject(
            AuthViewModel(
                loginUseCase: container.loginUseCase,
                logoutUseCase: container.logoutUseCase,
                getAuthState: container.getAuthStateUseCase
            )
        )
        .environmentObject(ThemeManager())
}
