//
//  EquityCard.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct EquityCard: View {
    var body: some View {
        VStack {
            Text("Total PnL").font(.title).foregroundStyle(.black)
            Text("$2,350")
                .font(.largeTitle)
                .bold()
        }
        .padding()
        .background(.profitGreen.opacity(0.2))
        .cornerRadius(12)
    }
}

#Preview {
    EquityCard()
}
