//
//  TradeListView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct TradeListView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    var body: some View {
        List(tradeViewModel.trades, id: \.self) { trade in
                    NavigationLink {
                        TradeDetailView(trade:trade)
                    } label: {
                        Text(trade.symbol)
                    }
                }
    }
}

#Preview {
    TradeListView()
}
