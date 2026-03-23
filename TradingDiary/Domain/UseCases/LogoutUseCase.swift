import Foundation

struct LogoutUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    @MainActor func execute() {
        repository.logout()
    }
}

