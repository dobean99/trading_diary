//
//  MainTabView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var showMenu = false
    private let menuWidth: CGFloat = 280
    
    var body: some View {
        ZStack(alignment: .leading) {
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

                NavigationStack {
                    CalendarView()
                }
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            }
            .disabled(showMenu)
            
            if showMenu {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showMenu = false
                        }
                    }
            }
            
            SideMenuView()
                .offset(x: showMenu ? 0 : -menuWidth - 24)
                .accessibilityHidden(!showMenu)
        }
        .animation(.easeInOut(duration: 0.25), value: showMenu)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width > 80 {
                        showMenu = true
                    }
                        
                    if value.translation.width < -80 {
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
