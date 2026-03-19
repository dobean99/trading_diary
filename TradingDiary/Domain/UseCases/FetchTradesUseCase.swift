import Foundation

struct FetchTradesUseCase {
    private let repository: TradeRepository

    init(repository: TradeRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Trade] {
        try await repository.fetchTrades()
    }
}
