//
//  SideMenuView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject private var auth: AuthViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var tradeViewModel: TradeViewModel

    private let menuItems: [MenuItem] = [
        .init(title: "Dashboard", icon: "chart.pie.fill"),
        .init(title: "Trades", icon: "list.bullet.rectangle.portrait"),
        .init(title: "Analytics", icon: "chart.line.uptrend.xyaxis"),
        .init(title: "Calendar", icon: "calendar")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            profileHeader
            menuSection
            appearanceCard
            Spacer(minLength: 0)
            logoutButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .frame(width: 280, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.backgroundColor, Color.card.opacity(0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.appPrimary.opacity(0.16))
                        .frame(width: 52, height: 52)
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(Color.appPrimary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Trading Profile")
                        .font(.system(size: 20, weight: .bold))
                    Text(auth.email.isEmpty ? "Local account" : auth.email)
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            Text("\(tradeViewModel.trades.count) trades tracked")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.top, 24)
    }

    private var menuSection: some View {
        VStack(spacing: 10) {
            ForEach(menuItems) { item in
                HStack(spacing: 12) {
                    Image(systemName: item.icon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color.appPrimary)
                        .frame(width: 28)
                    Text(item.title)
                        .font(.system(size: 16, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.card)
                )
            }
        }
    }

    private var appearanceCard: some View {
        HStack(spacing: 12) {
            Image(systemName: themeManager.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(themeManager.isDarkMode ? Color.appPrimary : Color.profit)

            VStack(alignment: .leading, spacing: 2) {
                Text("Dark Mode")
                    .font(.system(size: 16, weight: .semibold))
                Text(themeManager.isDarkMode ? "Enabled" : "Disabled")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Toggle("Dark Mode", isOn: $themeManager.isDarkMode)
                .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.card)
        )
    }

    private var logoutButton: some View {
        Button {
            auth.logout()
        } label: {
            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(Color.loss)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.loss.opacity(0.12))
                )
        }
        .buttonStyle(.plain)
        .padding(.bottom, 8)
    }
}

private struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

#Preview {
    let container = AppContainer()
    return SideMenuView()
        .environmentObject(ThemeManager())
        .environmentObject(
            TradeViewModel(
                fetchTrades: container.fetchTradesUseCase,
                addTrade: container.addTradeUseCase
            )
        )
        .environmentObject(
            AuthViewModel(
                loginUseCase: container.loginUseCase,
                logoutUseCase: container.logoutUseCase,
                getAuthState: container.getAuthStateUseCase
            )
        )
}
