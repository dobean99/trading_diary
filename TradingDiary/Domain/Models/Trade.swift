//
//  Trade.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct Trade: Identifiable, Hashable {

    let id = UUID()
    let symbol: String
    let entryPrice: Double
    let exitPrice: Double
    let size: Double
    let date: Date
    let strategy: String
    let note: String

    var pnl: Double {
        (exitPrice - entryPrice) * size
    }
}
