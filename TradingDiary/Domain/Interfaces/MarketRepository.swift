import Foundation

protocol MarketRepository {
    func fetchPrices() async throws -> MarketPriceSnapshot
}
