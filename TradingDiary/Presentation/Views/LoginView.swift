//
//  LoginView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/17/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @FocusState private var focusedField: Field?

    private enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        ZStack {
            Color.backgroundColor
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 6) {
                    Text("Trading Diary")
                        .font(.largeTitle.bold())
                    Text("Sign in to continue")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 10)

                VStack(alignment: .leading, spacing: 12) {
                    TextField("Email", text: $auth.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.username)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .email)
                        .onSubmit { focusedField = .password }
                        .padding()
                        .background(Color.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    SecureField("Password", text: $auth.password)
                        .textContentType(.password)
                        .submitLabel(.go)
                        .focused($focusedField, equals: .password)
                        .onSubmit { signIn() }
                        .padding()
                        .background(Color.card)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let error = auth.errorMessage {
                        Text(error)
                            .font(.footnote)
                            .foregroundStyle(Color.loss)
                    }
                }

                Button(action: signIn) {
                    HStack(spacing: 10) {
                        if auth.isLoading {
                            ProgressView()
                                .tint(.white)
                        }
                        Text(auth.isLoading ? "Signing in..." : "Sign In")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(auth.isLoading)

                Spacer(minLength: 0)
            }
            .padding(24)
            .frame(maxWidth: 520)
        }
        .onAppear { focusedField = .email }
    }

    private func signIn() {
        focusedField = nil
        auth.login()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
