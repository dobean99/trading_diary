import Foundation

protocol AuthRepository {
    var isAuthenticated: Bool { get }
    func login(email: String, password: String) throws
    func logout()
}

enum AuthError: LocalizedError, Equatable {
    case emailRequired
    case invalidEmail
    case passwordRequired

    var errorDescription: String? {
        switch self {
        case .emailRequired:
            "Email is required."
        case .invalidEmail:
            "Please enter a valid email."
        case .passwordRequired:
            "Password is required."
        }
    }
}

