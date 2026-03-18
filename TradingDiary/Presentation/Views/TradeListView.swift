//
//  TradeListView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct TradeListView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel

    private enum TradeFilter: String, CaseIterable, Identifiable {
        case all = "All"
        case long = "Long"
        case short = "Short"
        case winning = "Winning"
        case losing = "Losing"

        var id: String { rawValue }
    }

    @State private var filter: TradeFilter = .all

    private var filteredTrades: [Trade] {
        switch filter {
        case .all:
            return tradeViewModel.trades
        case .long:
            return tradeViewModel.trades.filter { $0.side == .long }
        case .short:
            return tradeViewModel.trades.filter { $0.side == .short }
        case .winning:
            return tradeViewModel.trades.filter { $0.pnl >= 0 }
        case .losing:
            return tradeViewModel.trades.filter { $0.pnl < 0 }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            filterChips

            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 14) {
                    ForEach(filteredTrades) { trade in
                        NavigationLink {
                            TradeDetailView(trade: trade)
                        } label: {
                            TradeRowCard(trade: trade)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .padding(.top, 8)
        .background(Color.backgroundColor.ignoresSafeArea())
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TradeFilter.allCases) { item in
                    Button {
                        withAnimation(.snappy) {
                            filter = item
                        }
                    } label: {
                        Text(item.rawValue)
                            .font(AppFont.caption)
                            .foregroundStyle(filter == item ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .fill(filter == item ? Color.appPrimary : Color.card)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

private struct TradeRowCard: View {
    let trade: Trade

    private var pillText: String { trade.side.rawValue }
    private var pillTextColor: Color { trade.side == .long ? .profit : .loss }
    private var pillBg: Color { pillTextColor.opacity(0.12) }

    private var pnlText: String {
        let value = trade.pnl
        return String(format: "$%.2f", abs(value))
    }

    private var pnlColor: Color {
        trade.pnl >= 0 ? Color.profit : Color.loss
    }

    private func priceText(_ value: Double) -> String {
        String(format: "$%.2f", value)
    }

    var body: some View {
        HStack(spacing: 14) {
            Text(pillText)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(pillTextColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(pillBg)
                )

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 10) {
                    Text("Entry")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(priceText(trade.entryPrice))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                }

                HStack(spacing: 10) {
                    Text("Exit")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.secondary)
                    Text(priceText(trade.exitPrice))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 8) {
                Text("Qty \(Int(trade.size))")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(pnlText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(pnlColor)
            }

            Button {
                // TODO: wire delete use case
            } label: {
                Image(systemName: "trash")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.red)
                    .padding(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
        )
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    let container = AppContainer()
    return TradeListView()
        .environmentObject(
            TradeViewModel(
                fetchTrades: container.fetchTradesUseCase,
                addTrade: container.addTradeUseCase
            )
        )
}
