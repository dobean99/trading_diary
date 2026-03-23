import Foundation

struct FetchMarketPricesUseCase {
    private let repository: MarketRepository

    init(repository: MarketRepository) {
        self.repository = repository
    }

    func execute() async throws -> MarketPriceSnapshot {
        try await repository.fetchPrices()
    }
}
