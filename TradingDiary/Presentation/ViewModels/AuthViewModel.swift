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

    func login() {
        errorMessage = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty else {
            errorMessage = "Email is required."
            return
        }

        guard trimmedEmail.contains("@") else {
            errorMessage = "Please enter a valid email."
            return
        }

        guard !trimmedPassword.isEmpty else {
            errorMessage = "Password is required."
            return
        }

        isLoading = true
        defer { isLoading = false }

        // Local-only auth placeholder (no backend yet).
        isAuthenticated = true
        password = ""
    }

    func logout() {
        isAuthenticated = false
        email = ""
        password = ""
        errorMessage = nil
    }
}
