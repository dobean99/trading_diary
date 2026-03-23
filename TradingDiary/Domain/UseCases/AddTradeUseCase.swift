import Foundation

struct AddTradeUseCase {
    private let repository: TradeRepository

    init(repository: TradeRepository) {
        self.repository = repository
    }

    func execute(_ trade: Trade, openedAt: Date, closedAt: Date?) async throws {
        try await repository.addTrade(trade, openedAt: openedAt, closedAt: closedAt)
    }
}
