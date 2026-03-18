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

    var body: some View {

        VStack(alignment: .leading, spacing: 30) {

            Text("Profile")
                .font(.largeTitle)
                .bold()
                .padding(.top, 50)

            Label("Dashboard", systemImage: "chart.pie")

            Label("Trades", systemImage: "list.bullet.rectangle")

            Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")

            Label("Settings", systemImage: "gearshape")

            HStack(spacing: 12) {
                Image(systemName: themeManager.isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                    .foregroundStyle(themeManager.isDarkMode ? Color.appPrimary : Color.profit)

                Text("Dark Mode")

                Spacer()

                Toggle("", isOn: $themeManager.isDarkMode)
                    .labelsHidden()
            }

            Spacer()

            Button {
                auth.logout()
            } label: {
                Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
            }
        }
        .frame(width: 260, alignment: .leading)
    }
}

#Preview {
    let container = AppContainer()
    return SideMenuView()
        .environmentObject(ThemeManager())
        .environmentObject(
            AuthViewModel(
                loginUseCase: container.loginUseCase,
                logoutUseCase: container.logoutUseCase,
                getAuthState: container.getAuthStateUseCase
            )
        )
}
