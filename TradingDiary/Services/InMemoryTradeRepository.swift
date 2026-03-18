import Foundation

@MainActor
final class InMemoryTradeRepository: TradeRepository {
    private var storage: [Trade] = [
        Trade(
            symbol: "AAPL",
            side: .long,
            entryPrice: 180.0,
            exitPrice: 185.5,
            size: 10,
            date: Date(),
            strategy: "Breakout",
            note: "Earnings momentum play"
        ),
        Trade(
            symbol: "TSLA",
            side: .long,
            entryPrice: 220.0,
            exitPrice: 210.0,
            size: 5,
            date: Date().addingTimeInterval(-86400),
            strategy: "Reversion",
            note: "Stopped out after failed bounce"
        ),
        Trade(
            symbol: "NVDA",
            side: .short,
            entryPrice: 800.0,
            exitPrice: 760.0,
            size: 2,
            date: Date().addingTimeInterval(-2 * 86400),
            strategy: "Trend following",
            note: "Rode the trend into close"
        ),
        Trade(
            symbol: "SPY",
            side: .short,
            entryPrice: 612.0,
            exitPrice: 585.5,
            size: 15,
            date: Date(),
            strategy: "Pullback",
            note: ""
        ),
        Trade(
            symbol: "MSFT",
            side: .long,
            entryPrice: 238.4,
            exitPrice: 231.2,
            size: 20,
            date: Date(),
            strategy: "Breakout",
            note: ""
        ),
        Trade(
            symbol: "META",
            side: .long,
            entryPrice: 182.5,
            exitPrice: 187.2,
            size: 50,
            date: Date(),
            strategy: "Trend following",
            note: ""
        )
    ]

    func fetchTrades() -> [Trade] {
        storage
    }

    func addTrade(_ trade: Trade) {
        storage.append(trade)
    }
}

