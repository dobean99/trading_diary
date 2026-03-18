import Foundation

@MainActor
final class AppContainer {
    // Repositories (Data layer)
    lazy var tradeRepository: TradeRepository = InMemoryTradeRepository()
    lazy var authRepository: AuthRepository = LocalAuthRepository()

    // Use cases (Domain layer)
    lazy var fetchTradesUseCase = FetchTradesUseCase(repository: tradeRepository)
    lazy var addTradeUseCase = AddTradeUseCase(repository: tradeRepository)

    lazy var loginUseCase = LoginUseCase(repository: authRepository)
    lazy var logoutUseCase = LogoutUseCase(repository: authRepository)
    lazy var getAuthStateUseCase = GetAuthStateUseCase(repository: authRepository)
}

