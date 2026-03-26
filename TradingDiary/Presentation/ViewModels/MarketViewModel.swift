import Foundation

@MainActor
final class MarketViewModel: ObservableObject {
    @Published var exchange: String = ""
    @Published var total: Int = 0
    @Published var items: [MarketPrice] = []
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let fetchMarketPrices: FetchMarketPricesUseCase
    private let fetchMarketOHLCV: FetchMarketOHLCVUseCase

    init(
        fetchMarketPrices: FetchMarketPricesUseCase,
        fetchMarketOHLCV: FetchMarketOHLCVUseCase
    ) {
        self.fetchMarketPrices = fetchMarketPrices
        self.fetchMarketOHLCV = fetchMarketOHLCV

        Task {
            await reload()
        }
    }

    func reload() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let snapshot = try await fetchMarketPrices.execute()
            exchange = snapshot.exchange
            total = snapshot.total
            items = snapshot.items
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadOHLCV(
        exchange: String,
        symbol: String,
        timeframe: String = "1h",
        limit: Int = 100
    ) async throws -> MarketOHLCVSnapshot {
        try await fetchMarketOHLCV.execute(
            exchange: exchange,
            symbol: symbol,
            timeframe: timeframe,
            limit: limit
        )
    }
}
