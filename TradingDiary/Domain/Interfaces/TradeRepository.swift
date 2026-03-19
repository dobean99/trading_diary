import Foundation

protocol TradeRepository {
    func fetchTrades() async throws -> [Trade]
    func addTrade(_ trade: Trade)
}
