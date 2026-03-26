import Foundation

struct FetchMarketOHLCVUseCase {
    private let repository: MarketRepository

    init(repository: MarketRepository) {
        self.repository = repository
    }

    func execute(
        exchange: String,
        symbol: String,
        timeframe: String,
        limit: Int
    ) async throws -> MarketOHLCVSnapshot {
        try await repository.fetchOHLCV(
            exchange: exchange,
            symbol: symbol,
            timeframe: timeframe,
            limit: limit
        )
    }
}
