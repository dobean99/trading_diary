//
//  MainTabView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        ZStack{
            
        }
        TabView{
            NavigationStack {
                DashboardView()
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
    }
}

#Preview {
    MainTabView()
}
