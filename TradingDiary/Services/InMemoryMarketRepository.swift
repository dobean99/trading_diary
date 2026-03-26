import Foundation

final class InMemoryMarketRepository: MarketRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    private var snapshot = MarketPriceSnapshot(
        exchange: "NASDAQ",
        total: 4,
        items: [
            .init(symbol: "AAPL", price: 184.25, change24hPct: 1.12),
            .init(symbol: "TSLA", price: 211.64, change24hPct: -2.08),
            .init(symbol: "NVDA", price: 905.52, change24hPct: 3.91),
            .init(symbol: "MSFT", price: 432.88, change24hPct: 0.76)
        ]
    )

    func fetchPrices() async throws -> MarketPriceSnapshot {
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "exchange", value: "bingx"),
            URLQueryItem(name: "spot_only", value: "true"),
            URLQueryItem(name: "active_only", value: "true"),
            URLQueryItem(name: "limit", value: "10")
        ]

        let result = try await networkManager.request(
            path: "/api/v1/markets/prices",
            method: .get,
            queryItems: queryItems,
            headers: ["Accept": "application/json"]
        )

        guard (200...299).contains(result.response.statusCode) else {
            let message = extractAPIErrorMessage(from: result.data)
                ?? "Failed to load market prices (\(result.response.statusCode))."
            throw MarketDataError.server(message: message)
        }

        let decoded = try decodeSnapshot(from: result.data)
        snapshot = decoded
        return decoded
    }

    func fetchOHLCV(
        exchange: String,
        symbol: String,
        timeframe: String,
        limit: Int
    ) async throws -> MarketOHLCVSnapshot {
        let queryItems = [
            URLQueryItem(name: "exchange", value: exchange),
            URLQueryItem(name: "symbol", value: symbol),
            URLQueryItem(name: "timeframe", value: timeframe),
            URLQueryItem(name: "limit", value: String(limit))
        ]

        let result = try await networkManager.request(
            path: "/api/v1/markets/ohlcv",
            method: .get,
            queryItems: queryItems,
            headers: ["Accept": "application/json"]
        )

        guard (200...299).contains(result.response.statusCode) else {
            let message = extractAPIErrorMessage(from: result.data)
                ?? "Failed to load OHLCV (\(result.response.statusCode))."
            throw MarketDataError.server(message: message)
        }

        return try decodeOHLCVSnapshot(from: result.data)
    }

    private func decodeSnapshot(from data: Data) throws -> MarketPriceSnapshot {
        let decoder = JSONDecoder()
        if let payload = try? decoder.decode(MarketPricesPayload.self, from: data) {
            return payload.asDomain
        }

        if let wrapped = try? decoder.decode(MarketPricesEnvelope.self, from: data) {
            return wrapped.data.asDomain
        }

        throw MarketDataError.invalidResponse
    }

    private func decodeOHLCVSnapshot(from data: Data) throws -> MarketOHLCVSnapshot {
        let decoder = JSONDecoder()
        if let payload = try? decoder.decode(MarketOHLCVPayload.self, from: data) {
            return payload.asDomain
        }

        if let wrapped = try? decoder.decode(MarketOHLCVEnvelope.self, from: data) {
            return wrapped.data.asDomain
        }

        throw MarketDataError.invalidResponse
    }
}

private struct MarketPricesEnvelope: Decodable {
    let data: MarketPricesPayload
}

private struct MarketPricesPayload: Decodable {
    let exchange: String
    let total: Int
    let items: [MarketPricePayload]

    var asDomain: MarketPriceSnapshot {
        MarketPriceSnapshot(
            exchange: exchange,
            total: total,
            items: items.map(\.asDomain)
        )
    }
}

private struct MarketPricePayload: Decodable {
    let symbol: String
    let price: Double
    let change24hPct: Double

    enum CodingKeys: String, CodingKey {
        case symbol
        case price
        case change24hPct = "change_24h_pct"
    }

    var asDomain: MarketPrice {
        MarketPrice(symbol: symbol, price: price, change24hPct: change24hPct)
    }
}

private struct MarketOHLCVEnvelope: Decodable {
    let data: MarketOHLCVPayload
}

private struct MarketOHLCVPayload: Decodable {
    let exchange: String
    let symbol: String
    let timeframe: String
    let total: Int
    let items: [OHLCVCandlePayload]

    var asDomain: MarketOHLCVSnapshot {
        MarketOHLCVSnapshot(
            exchange: exchange,
            symbol: symbol,
            timeframe: timeframe,
            total: total,
            items: items.map(\.asDomain)
        )
    }
}

private struct OHLCVCandlePayload: Decodable {
    let timestamp: TimeInterval
    let datetime: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double

    var asDomain: OHLCVCandle {
        OHLCVCandle(
            timestamp: timestamp,
            datetime: datetime,
            open: open,
            high: high,
            low: low,
            close: close,
            volume: volume
        )
    }
}

private enum MarketDataError: LocalizedError {
    case invalidResponse
    case server(message: String)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid market prices response."
        case .server(let message):
            return message
        }
    }
}

private func extractAPIErrorMessage(from data: Data) -> String? {
    guard let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
        return nil
    }

    if let message = object["message"] as? String, !message.isEmpty {
        return message
    }

    if let detail = object["detail"] as? String, !detail.isEmpty {
        return detail
    }

    if let details = object["detail"] as? [[String: Any]],
       let first = details.first,
       let message = first["msg"] as? String,
       !message.isEmpty
    {
        return message
    }

    return nil
}
