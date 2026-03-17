//
//  EquityCardView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct EquityCardView: View {
    var body: some View {
        VStack {
            Text("Total PnL")
            Text("$2,350")
                .font(.largeTitle)
                .bold()
        }
        .padding()
        .background(.green.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    EquityCardView()
}
