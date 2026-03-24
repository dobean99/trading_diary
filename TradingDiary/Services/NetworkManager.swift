import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: LocalizedError {
    case invalidBaseURL
    case invalidResponse
    case transportError
    case requestEncodingFailed

    var errorDescription: String? {
        switch self {
        case .invalidBaseURL:
            return "Invalid API base URL."
        case .invalidResponse:
            return "Invalid server response."
        case .transportError:
            return "Network request failed."
        case .requestEncodingFailed:
            return "Failed to encode request body."
        }
    }
}

final class NetworkManager {
    private let baseURL: URL?
    private let session: URLSession
    private var bearerToken: String?

    init(baseURLString: String = "http://127.0.0.1:18081", session: URLSession = .shared) {
        self.baseURL = URL(string: baseURLString)
        self.session = session
    }

    func setBearerToken(_ token: String?) {
        let value = token?.trimmingCharacters(in: .whitespacesAndNewlines)
        bearerToken = (value?.isEmpty == false) ? value : nil
    }

    func request(
        path: String,
        method: HTTPMethod,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil,
        headers: [String: String] = [:],
        timeout: TimeInterval = 15
    ) async throws -> (data: Data, response: HTTPURLResponse) {
        guard let baseURL else {
            throw APIError.invalidBaseURL
        }

        let normalizedPath = path.hasPrefix("/") ? path : "/\(path)"
        let resolvedURL = baseURL.appendingPathComponent(String(normalizedPath.dropFirst()))
        guard var components = URLComponents(url: resolvedURL, resolvingAgainstBaseURL: false) else {
            throw APIError.invalidBaseURL
        }

        if let queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            throw APIError.invalidBaseURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.timeoutInterval = timeout

        headers.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        if request.value(forHTTPHeaderField: "Authorization") == nil, let bearerToken {
            request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            do {
                request.httpBody = try makeEncoder().encode(AnyEncodable(body))
                if headers["Content-Type"] == nil {
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                }
            } catch {
                throw APIError.requestEncodingFailed
            }
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            return (data, httpResponse)
        } catch {
            throw APIError.transportError
        }
    }
}

private func makeEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
        var container = encoder.singleValueContainer()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        try container.encode(formatter.string(from: date))
    }
    return encoder
}

private struct AnyEncodable: Encodable {
    private let encodeHandler: (Encoder) throws -> Void

    init(_ wrapped: Encodable) {
        self.encodeHandler = { encoder in
            try wrapped.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeHandler(encoder)
    }
}
