//
//  SideMenuView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI


struct SideMenuView: View {
    @EnvironmentObject private var auth: AuthViewModel

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
