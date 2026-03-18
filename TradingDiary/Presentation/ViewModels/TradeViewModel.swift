//
//  TradeViewModel.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//
import Foundation

@MainActor
final class TradeViewModel: ObservableObject {

    @Published var trades: [Trade] = []

    private let fetchTrades: FetchTradesUseCase
    private let addTrade: AddTradeUseCase

    init(
        fetchTrades: FetchTradesUseCase,
        addTrade: AddTradeUseCase
    ) {
        self.fetchTrades = fetchTrades
        self.addTrade = addTrade
        self.trades = fetchTrades.execute()
    }

    func addTrade(symbol: String, side: Trade.Side = .long, entry: Double, exit: Double) {
        let trade = Trade(
            symbol: symbol,
            side: side,
            entryPrice: entry,
            exitPrice: exit,
            size: 1,
            date: Date(),
            strategy: "Breakout",
            note: ""
        )

        addTrade.execute(trade)
        trades = fetchTrades.execute()
    }
}
