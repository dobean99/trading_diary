//
//  DashboardView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct DashboardView: View {
    @Binding var showMenu: Bool
    
    var body: some View {
        VStack(spacing: 20){
            Button {
                
                withAnimation {
                    showMenu.toggle()
                }
                
            } label: {
                
                Image(systemName: "person.circle")
                    .font(.title2)
            }
            NavigationLink(value: Route.addTrade){
                EquityCard()
            }
            PerformanceCard()
            TradeListView()
        }
    }
}

#Preview {
    DashboardView(showMenu: .constant(true))
}
