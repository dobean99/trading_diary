//
//  Trade.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import Foundation

struct Trade: Identifiable, Hashable {

    enum Side: String, CaseIterable, Hashable {
        case long = "LONG"
        case short = "SHORT"
    }

    let id = UUID()
    let symbol: String
    let side: Side
    let entryPrice: Double
    let exitPrice: Double
    let size: Double
    let date: Date
    let strategy: String
    let note: String

    var pnl: Double {
        switch side {
        case .long:
            (exitPrice - entryPrice) * size
        case .short:
            (entryPrice - exitPrice) * size
        }
    }
}
