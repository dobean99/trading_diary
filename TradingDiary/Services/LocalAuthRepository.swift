import Foundation

@MainActor
final class LocalAuthRepository: AuthRepository {
    private(set) var isAuthenticated: Bool = false
    private let loginURL = URL(string: "http://localhost:8000/api/v1/login")

    func login(email: String, password: String) async throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else { throw AuthError.emailRequired }
        guard trimmedEmail.contains("@") else { throw AuthError.invalidEmail }
        guard !trimmedPassword.isEmpty else { throw AuthError.passwordRequired }
        guard let loginURL else { throw AuthError.invalidResponse }

        var request = URLRequest(url: loginURL)
        request.httpMethod = "POST"
        request.timeoutInterval = 15
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(LoginRequest(email: trimmedEmail, password: trimmedPassword))

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AuthError.invalidResponse
            }

            switch httpResponse.statusCode {
            case 200 ... 299:
                isAuthenticated = true
            case 401:
                throw AuthError.invalidCredentials
            default:
                let message = extractErrorMessage(from: data) ?? "Login failed (\(httpResponse.statusCode))."
                throw AuthError.server(message: message)
            }
        } catch let authError as AuthError {
            throw authError
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
