import Foundation

struct LoginUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(email: String, password: String) async throws {
        try await repository.login(email: email, password: password)
    }
}
