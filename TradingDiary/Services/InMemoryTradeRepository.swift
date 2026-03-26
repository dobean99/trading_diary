import Foundation

@MainActor
final class InMemoryTradeRepository: TradeRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    private var storage: [Trade] = []

    func fetchTrades() async throws -> [Trade] {
        do {
            let result = try await networkManager.request(
                path: "/api/v1/trades",
                method: .get,
                headers: ["Accept": "application/json"]
            )
            guard (200...299).contains(result.response.statusCode) else {
                return storage
            }

            let remoteTrades = try decodeTrades(from: result.data)
            storage = remoteTrades
            return remoteTrades
        } catch {
            return storage
        }
    }

    private func decodeTrades(from data: Data) throws -> [Trade] {
        if let array = try? makeDecoder().decode([TradePayload].self, from: data) {
            return array.map(\.asDomainTrade)
        }

        if let wrapped = try? makeDecoder().decode(TradesEnvelope.self, from: data) {
            return wrapped.data.map(\.asDomainTrade)
        }

        return storage
    }

    func addTrade(_ trade: Trade, openedAt: Date, closedAt: Date?) async throws {
        let payload = AddTradeRequest(
            symbol: trade.symbol,
            side: trade.side == .long ? "BUY" : "SELL",
            quantity: trade.size,
            entryPrice: trade.entryPrice,
            exitPrice: trade.exitPrice,
            openedAt: openedAt,
            closedAt: closedAt ?? openedAt,
            notes: trade.note
        )

        let result = try await networkManager.request(
            path: "/api/v1/trades",
            method: .post,
            body: payload,
            headers: [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
        )

        guard (200...299).contains(result.response.statusCode) else {
            throw APIError.invalidResponse
        }

        storage.append(trade)
    }
}

private struct TradesEnvelope: Decodable {
    let data: [TradePayload]
}

private struct TradePayload: Decodable {
    let symbol: String
    let side: String
    let entryPrice: Double
    let exitPrice: Double
    let size: Double
    let date: Date?
    let strategy: String?
    let note: String?

    enum CodingKeys: String, CodingKey {
        case symbol
        case side
        case entryPrice
        case entryPriceSnake = "entry_price"
        case exitPrice
        case exitPriceSnake = "exit_price"
        case size
        case date
        case strategy
        case note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        symbol = try container.decode(String.self, forKey: .symbol)
        side = try container.decode(String.self, forKey: .side)
        entryPrice =
            (try? container.decode(Double.self, forKey: .entryPrice))
            ?? (try? container.decode(Double.self, forKey: .entryPriceSnake))
            ?? 0
        exitPrice =
            (try? container.decode(Double.self, forKey: .exitPrice))
            ?? (try? container.decode(Double.self, forKey: .exitPriceSnake))
            ?? 0
        size = (try? container.decode(Double.self, forKey: .size)) ?? 1
        date = try? container.decode(Date.self, forKey: .date)
        strategy = try? container.decode(String.self, forKey: .strategy)
        note = try? container.decode(String.self, forKey: .note)
    }

    var asDomainTrade: Trade {
        let normalizedSide = side.lowercased()
        let mappedSide: Trade.Side =
            (normalizedSide == "short" || normalizedSide == "sell") ? .short : .long
        return Trade(
            symbol: symbol,
            side: mappedSide,
            entryPrice: entryPrice,
            exitPrice: exitPrice,
            size: size,
            date: date ?? .now,
            strategy: strategy ?? "API",
            note: note ?? ""
        )
    }
}

private func makeDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()

        if let timestamp = try? container.decode(Double.self) {
            return Date(timeIntervalSince1970: timestamp)
        }

        if let intTimestamp = try? container.decode(Int.self) {
            return Date(timeIntervalSince1970: Double(intTimestamp))
        }

        if let dateString = try? container.decode(String.self) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsedDate = isoFormatter.date(from: dateString) {
                return parsedDate
            }

            let fallbackFormatter = ISO8601DateFormatter()
            if let parsedDate = fallbackFormatter.date(from: dateString) {
                return parsedDate
            }
        }

        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported date format")
    }
    return decoder
}

private struct AddTradeRequest: Encodable {
    let symbol: String
    let side: String
    let quantity: Double
    let entryPrice: Double
    let exitPrice: Double
    let openedAt: Date
    let closedAt: Date
    let notes: String

    enum CodingKeys: String, CodingKey {
        case symbol
        case side
        case quantity
        case entryPrice = "entry_price"
        case exitPrice = "exit_price"
        case openedAt = "opened_at"
        case closedAt = "closed_at"
        case notes
    }
}
