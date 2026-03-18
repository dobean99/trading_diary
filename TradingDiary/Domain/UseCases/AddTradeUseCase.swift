import Foundation

struct AddTradeUseCase {
    private let repository: TradeRepository

    init(repository: TradeRepository) {
        self.repository = repository
    }

    func execute(_ trade: Trade) {
        repository.addTrade(trade)
    }
}

