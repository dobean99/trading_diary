import Foundation

struct MarketPriceSnapshot: Hashable {
    let exchange: String
    let total: Int
    let items: [MarketPrice]
}

struct MarketPrice: Identifiable, Hashable {
    let symbol: String
    let price: Double
    let change24hPct: Double

    var id: String { symbol }
}
