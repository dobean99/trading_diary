//
//  TradeDetailView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/18/26.
//

import SwiftUI

struct TradeDetailView: View {
    @State var trade: Trade

    var body: some View {
        VStack{
            Text("Name: \(trade.symbol)")
            Text("Side: \(trade.side.rawValue)")
            Text("entryPrice: \(trade.entryPrice)")
            Text("exitPrice: \(trade.exitPrice)")
            Text("Date: \(trade.date)")
            Text("Note: \(trade.note)")
        }
       
    }
}
