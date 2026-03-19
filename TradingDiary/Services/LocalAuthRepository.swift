import Foundation

@MainActor
final class LocalAuthRepository: AuthRepository {
    private(set) var isAuthenticated: Bool = false
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }

    func login(email: String, password: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else { throw AuthError.emailRequired }
        guard trimmedEmail.contains("@") else { throw AuthError.invalidEmail }
        guard !trimmedPassword.isEmpty else { throw AuthError.passwordRequired }

        do {
            let result = try await networkManager.request(
                path: "/api/v1/login",
                method: .post,
                body: LoginRequest(email: trimmedEmail, password: trimmedPassword),
                headers: [
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                ]
            )

            switch result.response.statusCode {
            case 200 ... 299:
                isAuthenticated = true
            case 401:
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
        isAuthenticated = false
    }
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
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
