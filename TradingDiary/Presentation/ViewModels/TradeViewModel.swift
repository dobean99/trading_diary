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

    @discardableResult
    func addTrade(
        symbol: String,
        side: Trade.Side = .long,
        quantity: Double = 1,
        entry: Double,
        exit: Double,
        openedAt: Date = .now,
        closedAt: Date? = nil,
        notes: String = "",
        strategy: String = "Manual"
    ) async -> Bool {
        let trade = Trade(
            symbol: symbol,
            side: side,
            entryPrice: entry,
            exitPrice: exit,
            size: quantity,
            date: closedAt ?? openedAt,
            strategy: strategy,
            note: notes
        )

        do {
            try await addTrade.execute(trade, openedAt: openedAt, closedAt: closedAt)
            await reloadTrades()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    @discardableResult
    func addTrade(symbol: String, side: Trade.Side = .long, entry: Double, exit: Double) async -> Bool {
        await addTrade(
            symbol: symbol,
            side: side,
            quantity: 1,
            entry: entry,
            exit: exit,
            openedAt: .now,
            closedAt: nil,
            notes: "",
            strategy: "Manual"
        )
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
