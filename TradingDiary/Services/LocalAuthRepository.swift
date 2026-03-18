import Foundation

@MainActor
final class LocalAuthRepository: AuthRepository {
    private(set) var isAuthenticated: Bool = false

    func login(email: String, password: String) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else { throw AuthError.emailRequired }
        guard trimmedEmail.contains("@") else { throw AuthError.invalidEmail }
        guard !trimmedPassword.isEmpty else { throw AuthError.passwordRequired }

        // Local-only placeholder (no backend yet).
        isAuthenticated = true
    }

    func logout() {
        isAuthenticated = false
    }
}

