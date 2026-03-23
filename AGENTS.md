# Repository Guidelines

## Project Structure & Module Organization
`TradingDiary` is an iOS SwiftUI app using MVVM + Clean Architecture.

- `TradingDiary/Presentation/Views`: SwiftUI screens (`DashboardView`, `AddTradeView`, etc.)
- `TradingDiary/Presentation/ViewModels`: `ObservableObject` state and async UI actions
- `TradingDiary/Domain/Models`: pure domain types (`Trade`)
- `TradingDiary/Domain/Interfaces`: repository protocols
- `TradingDiary/Domain/UseCases`: app actions (`FetchTradesUseCase`, `AddTradeUseCase`)
- `TradingDiary/Services`: concrete repository/network/auth implementations
- `TradingDiary/Components`: reusable UI pieces
- `TradingDiary/Extensions`: shared style helpers (`AppColor`, `AppFont`)
- `TradingDiary/Assets.xcassets`: app color/icon assets

Dependency rule: `View -> ViewModel -> UseCase -> Repository protocol <- Service implementation`.

## Build, Test, and Development Commands
- `open TradingDiary.xcodeproj`  
  Open in Xcode for day-to-day development.
- `xcodebuild -project TradingDiary.xcodeproj -scheme TradingDiary -destination 'generic/platform=iOS' -derivedDataPath /tmp/TradingDiaryDerived CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO build`  
  CLI build check without signing.
- `xcodebuild -project TradingDiary.xcodeproj -scheme TradingDiary -destination 'platform=iOS Simulator,name=iPhone 16' build`  
  Full simulator build (requires local simulator runtime).

## Coding Style & Naming Conventions
- Use Swift defaults: 4-space indentation, no tabs.
- Types: `UpperCamelCase`; methods/properties: `lowerCamelCase`.
- Keep files focused: one main type per file when practical.
- Keep Domain layer UI-free and framework-light.
- Prefer `async/await` over callback-based networking.
- Name use cases with verb phrases: `LoginUseCase`, `FetchTradesUseCase`.

## Testing Guidelines
There is currently no committed test target. For new logic, add XCTest coverage when introducing non-trivial behavior (mapping, parsing, business rules). Prefer unit tests for `Domain/UseCases` and service decoding paths.

## Commit & Pull Request Guidelines
Recent commits use short imperative messages (e.g., `update trade`, `add statistics view`). Follow that baseline, but be more specific when possible:
- `add trade POST /api/v1/trades`
- `refactor trade decoding for BUY/SELL`

PRs should include:
- concise summary of behavior changes
- impacted layers/files
- screenshots or recordings for UI changes
- validation notes (build command run, simulator/device tested)
