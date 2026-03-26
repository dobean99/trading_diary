import Foundation

@MainActor
final class AppContainer {
    lazy var networkManager = NetworkManager(baseURLString: "http://127.0.0.1:18081")

    // Repositories (Data layer)
    lazy var tradeRepository: TradeRepository = InMemoryTradeRepository(networkManager: networkManager)
    lazy var authRepository: AuthRepository = LocalAuthRepository(networkManager: networkManager)
    lazy var marketRepository: MarketRepository = InMemoryMarketRepository(networkManager: networkManager)

    // Use cases (Domain layer)
    lazy var fetchTradesUseCase = FetchTradesUseCase(repository: tradeRepository)
    lazy var addTradeUseCase = AddTradeUseCase(repository: tradeRepository)
    lazy var fetchMarketPricesUseCase = FetchMarketPricesUseCase(repository: marketRepository)
    lazy var fetchMarketOHLCVUseCase = FetchMarketOHLCVUseCase(repository: marketRepository)

    lazy var loginUseCase = LoginUseCase(repository: authRepository)
    lazy var logoutUseCase = LogoutUseCase(repository: authRepository)
    lazy var getAuthStateUseCase = GetAuthStateUseCase(repository: authRepository)
}
