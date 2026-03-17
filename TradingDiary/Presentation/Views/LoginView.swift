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
    @State private var appear = false

    private enum Field: Hashable {
        case email
        case password
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.backgroundColor,
                    Color.primary.opacity(0.12),
                    Color.backgroundColor
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 10) {
                    Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                        .font(.system(size: 56, weight: .semibold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(Color.primary, Color.primary.opacity(0.25))
                        .shadow(color: Color.primary.opacity(0.25), radius: 14, y: 6)

                    VStack(spacing: 6) {
                        Text("Trading Diary")
                            .font(.largeTitle.bold())
                        Text("Sign in to continue")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.bottom, 6)

                VStack(alignment: .leading, spacing: 12) {
                    field(
                        title: "Email",
                        systemImage: "envelope",
                        content: AnyView(
                            TextField("name@email.com", text: $auth.email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .textContentType(.username)
                                .submitLabel(.next)
                                .focused($focusedField, equals: .email)
                                .onSubmit { focusedField = .password }
                        )
                    )

                    field(
                        title: "Password",
                        systemImage: "lock",
                        content: AnyView(
                            SecureField("Your password", text: $auth.password)
                                .textContentType(.password)
                                .submitLabel(.go)
                                .focused($focusedField, equals: .password)
                                .onSubmit { signIn() }
                        )
                    )

                    if let error = auth.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(Color.loss)
                            Text(error)
                                .font(.footnote)
                                .foregroundStyle(Color.loss)
                        }
                        .padding(.top, 2)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.card)
                        .shadow(color: .black.opacity(0.08), radius: 20, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                )

                Button(action: signIn) {
                    HStack(spacing: 10) {
                        if auth.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 18, weight: .semibold))
                        }

                        Text(auth.isLoading ? "Signing in..." : "Sign In")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.primary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.primary.opacity(0.35), radius: 16, y: 10)
                }
                .disabled(auth.isLoading)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .frame(maxWidth: 520)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 14)
            .animation(.easeOut(duration: 0.35), value: appear)
        }
        .onAppear {
            focusedField = .email
            appear = true
        }
    }

    private func signIn() {
        focusedField = nil
        auth.login()
    }

    private func field(title: String, systemImage: String, content: AnyView) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            content
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(Color.backgroundColor.opacity(0.55))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.primary.opacity(0.12), lineWidth: 1)
                )
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
