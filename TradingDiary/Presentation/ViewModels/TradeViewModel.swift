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
    @Published var errorMessage: String? = nil

    private let fetchTrades: FetchTradesUseCase
    private let addTrade: AddTradeUseCase

    init(
        fetchTrades: FetchTradesUseCase,
        addTrade: AddTradeUseCase
    ) {
        self.fetchTrades = fetchTrades
        self.addTrade = addTrade

        Task {
            await reloadTrades()
        }
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
        Task {
            await reloadTrades()
        }
    }

    func reloadTrades() async {
        do {
            trades = try await fetchTrades.execute()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
