import Foundation

protocol TradeRepository {
    func fetchTrades() -> [Trade]
    func addTrade(_ trade: Trade)
}

