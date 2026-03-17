//
//  AddTradeView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct AddTradeView: View {
    
    @State var symbol = ""
    @State var entry = ""
    @State var exit = ""
    @EnvironmentObject var vm: TradeViewModel
    
    var body: some View {
        
        Form {
            
            TextField("Symbol", text: $symbol)
            
            TextField("Entry Price", text: $entry)
                .keyboardType(.decimalPad)
            
            TextField("Exit Price", text: $exit)
                .keyboardType(.decimalPad)
            Button("Save Trade") {
                print("save trade")
                vm.addTrade(
                    symbol: symbol,
                    entry:  Double(entry) ?? 0,
                    exit: Double(exit) ?? 0
                )
            }
        }
    }
}

#Preview {
    AddTradeView()
}

