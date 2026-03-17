//
//  TradeViewModel.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//
import SwiftUI

class TradeViewModel: ObservableObject {

    @Published var trades: [Trade] = []

    func addTrade(symbol: String, entry: Double, exit: Double) {
    let trade = Trade(
            symbol: symbol,
            entryPrice: entry,
            exitPrice: exit,
            size: 1,
            date: Date(),
            strategy: "Breakout",
            note: ""
        )

        trades.append(trade)
    }
}
