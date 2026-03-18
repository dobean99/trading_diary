import Foundation

@MainActor
final class InMemoryTradeRepository: TradeRepository {
    private var storage: [Trade] = []

    func fetchTrades() -> [Trade] {
        storage
    }

    func addTrade(_ trade: Trade) {
        storage.append(trade)
    }
}

