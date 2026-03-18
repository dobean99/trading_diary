//
//  AuthViewModel.swift
//  TradingDiary
//
//  Created by dnkdo on 3/17/26.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String? = nil
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false

    private let loginUseCase: LoginUseCase
    private let logoutUseCase: LogoutUseCase
    private let getAuthState: GetAuthStateUseCase

    init(
        loginUseCase: LoginUseCase,
        logoutUseCase: LogoutUseCase,
        getAuthState: GetAuthStateUseCase
    ) {
        self.loginUseCase = loginUseCase
        self.logoutUseCase = logoutUseCase
        self.getAuthState = getAuthState
        self.isAuthenticated = getAuthState.execute()
    }

    func login() {
        errorMessage = nil

        isLoading = true
        defer { isLoading = false }

        do {
            try loginUseCase.execute(email: email, password: password)
            isAuthenticated = getAuthState.execute()
            password = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func logout() {
        logoutUseCase.execute()
        isAuthenticated = getAuthState.execute()
        email = ""
        password = ""
        errorMessage = nil
    }
}
