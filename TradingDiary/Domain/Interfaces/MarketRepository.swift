import Foundation

protocol MarketRepository {
    func fetchPrices() async throws -> MarketPriceSnapshot
    func fetchOHLCV(
        exchange: String,
        symbol: String,
        timeframe: String,
        limit: Int
    ) async throws -> MarketOHLCVSnapshot
}
