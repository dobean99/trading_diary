# TradingDiary

## Architecture

This project is organized as **MVVM + Clean Architecture**, with a lightweight “modular” structure using folders that map to boundaries.

### Layers

- **Presentation** (`TradingDiary/Presentation`)
  - SwiftUI views live in `Views/`
  - ViewModels are `ObservableObject` and depend only on **UseCases** (not Services)
- **Domain** (`TradingDiary/Domain`)
  - **Models**: pure Swift structs (no SwiftUI)
  - **Interfaces**: repository protocols (e.g. `TradeRepository`, `AuthRepository`)
  - **UseCases**: small structs that orchestrate Domain actions (e.g. `AddTradeUseCase`)
- **Data / Services** (`TradingDiary/Services`)
  - Concrete implementations of Domain interfaces (e.g. `InMemoryTradeRepository`, `LocalAuthRepository`)
  - **Composition root**: `AppContainer` builds repositories + use cases

### Dependency rule (Clean)

UI → ViewModel → UseCase → Repository (protocol) ← Service (implementation)

`TradingDiaryApp` is the only place that “knows everything” and wires dependencies.
