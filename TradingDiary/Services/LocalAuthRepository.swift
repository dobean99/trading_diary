import Foundation

@MainActor
final class LocalAuthRepository: AuthRepository {
    private(set) var isAuthenticated: Bool = false
    private let networkManager: NetworkManager
    private let tokenStore: JWTTokenStore

    init(
        networkManager: NetworkManager = NetworkManager(),
        tokenStore: JWTTokenStore = KeychainJWTTokenStore()
    ) {
        self.networkManager = networkManager
        self.tokenStore = tokenStore

        if let storedToken = tokenStore.loadToken(), !isTokenExpired(storedToken) {
            networkManager.setBearerToken(storedToken)
            isAuthenticated = true
        } else {
            clearSession()
        }
    }

    func login(email: String, password: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else { throw AuthError.emailRequired }
        guard trimmedEmail.contains("@") else { throw AuthError.invalidEmail }
        guard !trimmedPassword.isEmpty else { throw AuthError.passwordRequired }

        do {
            let result = try await networkManager.request(
                path: "/api/v1/auth/login",
                method: .post,
                body: LoginRequest(username: trimmedEmail, password: trimmedPassword),
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]
            )

            switch result.response.statusCode {
            case 200 ... 299:
                let tokenResponse = try decodeTokenResponse(from: result.data)
                guard tokenResponse.tokenType.lowercased() == "bearer" else {
                    throw AuthError.invalidResponse
                }
                guard !isTokenExpired(tokenResponse.accessToken) else {
                    throw AuthError.invalidResponse
                }

                do {
                    try tokenStore.save(token: tokenResponse.accessToken)
                } catch {
                    throw AuthError.network(message: error.localizedDescription)
                }

                networkManager.setBearerToken(tokenResponse.accessToken)
                isAuthenticated = true
            case 401:
                clearSession()
                throw AuthError.invalidCredentials
            default:
                let message = extractErrorMessage(from: result.data) ?? "Login failed (\(result.response.statusCode))."
                throw AuthError.server(message: message)
            }
        } catch let authError as AuthError {
            throw authError
        } catch let apiError as APIError {
            throw AuthError.network(message: apiError.localizedDescription)
        } catch {
            throw AuthError.network(message: "Unable to connect to login server.")
        }
    }

    func logout() {
        clearSession()
    }

    private func clearSession() {
        networkManager.setBearerToken(nil)
        tokenStore.clearToken()
        isAuthenticated = false
    }
}

private struct LoginRequest: Encodable {
    let username: String
    let password: String
}

private struct LoginTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
    }
}

private func decodeTokenResponse(from data: Data) throws -> LoginTokenResponse {
    let decoded = try JSONDecoder().decode(LoginTokenResponse.self, from: data)
    guard !decoded.accessToken.isEmpty else {
        throw AuthError.invalidResponse
    }
    return decoded
}

private func isTokenExpired(_ token: String) -> Bool {
    let parts = token.split(separator: ".")
    guard parts.count == 3 else {
        return true
    }

    var payload = String(parts[1])
        .replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/")

    while payload.count % 4 != 0 {
        payload.append("=")
    }

    guard
        let payloadData = Data(base64Encoded: payload),
        let object = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
        let exp = object["exp"] as? TimeInterval
    else {
        return true
    }

    return Date().timeIntervalSince1970 >= exp
}

private func extractErrorMessage(from data: Data) -> String? {
    guard
        let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    else {
        return nil
    }

    if let message = object["message"] as? String, !message.isEmpty {
        return message
    }

    if let detail = object["detail"] as? String, !detail.isEmpty {
        return detail
    }

    if let error = object["error"] as? String, !error.isEmpty {
        return error
    }

    return nil
}
