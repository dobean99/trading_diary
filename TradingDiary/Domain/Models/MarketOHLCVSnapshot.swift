import Foundation

struct MarketOHLCVSnapshot: Hashable {
    let exchange: String
    let symbol: String
    let timeframe: String
    let total: Int
    let items: [OHLCVCandle]
}

struct OHLCVCandle: Identifiable, Hashable {
    let timestamp: TimeInterval
    let datetime: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double

    var id: TimeInterval { timestamp }

    var date: Date {
        if timestamp > 9_999_999_999 {
            return Date(timeIntervalSince1970: timestamp / 1000)
        }
        return Date(timeIntervalSince1970: timestamp)
    }
}
