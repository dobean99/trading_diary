import Foundation

struct GetAuthStateUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.isAuthenticated
    }
}

