import Foundation

@MainActor
protocol AuthRepository {
    var isAuthenticated: Bool { get }
    func login(email: String, password: String) async throws
    func logout()
}

enum AuthError: LocalizedError, Equatable {
    case emailRequired
    case invalidEmail
    case passwordRequired
    case invalidResponse
    case invalidCredentials
    case server(message: String)
    case network(message: String)

    var errorDescription: String? {
        switch self {
        case .emailRequired:
            "Email is required."
        case .invalidEmail:
            "Please enter a valid email."
        case .passwordRequired:
            "Password is required."
        case .invalidResponse:
            "Unexpected response from server."
        case .invalidCredentials:
            "Invalid email or password."
        case .server(let message):
            message
        case .network(let message):
            message
        }
    }
}
