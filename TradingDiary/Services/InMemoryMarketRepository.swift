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
        let result = try await networkManager.request(
            path: "/api/v1/markets/prices",
            method: .get,
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
