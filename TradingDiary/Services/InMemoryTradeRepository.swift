import Foundation

@MainActor
final class InMemoryTradeRepository: TradeRepository {
    private var storage: [Trade] = [
        Trade(
            symbol: "AAPL",
            entryPrice: 180.0,
            exitPrice: 185.5,
            size: 10,
            date: Date(),
            strategy: "Breakout",
            note: "Earnings momentum play"
        ),
        Trade(
            symbol: "TSLA",
            entryPrice: 220.0,
            exitPrice: 210.0,
            size: 5,
            date: Date().addingTimeInterval(-86400),
            strategy: "Reversion",
            note: "Stopped out after failed bounce"
        ),
        Trade(
            symbol: "NVDA",
            entryPrice: 800.0,
            exitPrice: 830.0,
            size: 2,
            date: Date().addingTimeInterval(-2 * 86400),
            strategy: "Trend following",
            note: "Rode the trend into close"
        )
    ]

    func fetchTrades() -> [Trade] {
        storage
    }

    func addTrade(_ trade: Trade) {
        storage.append(trade)
    }
}

