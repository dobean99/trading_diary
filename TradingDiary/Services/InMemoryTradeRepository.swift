import Foundation

@MainActor
final class InMemoryTradeRepository: TradeRepository {
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    private var storage: [Trade] = [
        Trade(
            symbol: "AAPL",
            side: .long,
            entryPrice: 180.0,
            exitPrice: 185.5,
            size: 10,
            date: Date(),
            strategy: "Breakout",
            note: "Earnings momentum play"
        ),
        Trade(
            symbol: "TSLA",
            side: .long,
            entryPrice: 220.0,
            exitPrice: 210.0,
            size: 5,
            date: Date().addingTimeInterval(-86400),
            strategy: "Reversion",
            note: "Stopped out after failed bounce"
        ),
        Trade(
            symbol: "NVDA",
            side: .short,
            entryPrice: 800.0,
            exitPrice: 760.0,
            size: 2,
            date: Date().addingTimeInterval(-2 * 86400),
            strategy: "Trend following",
            note: "Rode the trend into close"
        ),
        Trade(
            symbol: "SPY",
            side: .short,
            entryPrice: 612.0,
            exitPrice: 585.5,
            size: 15,
            date: Date(),
            strategy: "Pullback",
            note: ""
        ),
        Trade(
            symbol: "MSFT",
            side: .long,
            entryPrice: 238.4,
            exitPrice: 231.2,
            size: 20,
            date: Date(),
            strategy: "Breakout",
            note: ""
        ),
        Trade(
            symbol: "META",
            side: .long,
            entryPrice: 182.5,
            exitPrice: 187.2,
            size: 50,
            date: Date(),
            strategy: "Trend following",
            note: ""
        )
    ]

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

    func addTrade(_ trade: Trade) {
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
        let mappedSide: Trade.Side = side.lowercased() == "short" ? .short : .long
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
