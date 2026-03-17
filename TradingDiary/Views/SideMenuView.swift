struct SideMenuView: View {

    var body: some View {

        VStack(alignment: .leading, spacing: 25) {

            Text("Trading Diary")
                .font(.title)
                .bold()
                .padding(.top, 40)

            Label("Dashboard", systemImage: "chart.pie")

            Label("Trades", systemImage: "list.bullet.rectangle")

            Label("Statistics", systemImage: "chart.line.uptrend.xyaxis")

            Label("Settings", systemImage: "gearshape")

            Spacer()
        }
        .padding()
        .frame(maxWidth: 250, alignment: .leading)
        .background(Color(.systemBackground))
    }
}