//
//  DashboardView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @Binding var showMenu: Bool
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @EnvironmentObject private var marketViewModel: MarketViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    dateRow
                    statsGrid
                    performanceSection
                    tradeQualitySection
                    marketPricesSection
                    todaysTradesSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 32)
            }
            .background(Color.backgroundColor.ignoresSafeArea())
            .task {
                await marketViewModel.reload()
            }
        }
    }
    
    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Trading Dashboard")
                    .font(AppFont.title)
                Text("6 February 2026")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                withAnimation {
                    showMenu.toggle()
                }
            } label: {
                Image(systemName: "person.crop.circle")
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            Button {
                // Add trade
            } label: {
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(Color.appPrimary)
                    .clipShape(Circle())
                    .shadow(color: Color.appPrimary.opacity(0.4), radius: 6, x: 0, y: 3)
            }
        }
    }
    
    private var dateRow: some View {
        Text("6 February 2026")
            .font(AppFont.caption)
            .foregroundStyle(.secondary)
    }
    
    private struct PerformancePoint: Identifiable {
        let id = UUID()
        let time: Date
        let value: Double
    }
    
    private var performanceData: [PerformancePoint] {
        let now = Date()
        return [
            PerformancePoint(time: now.addingTimeInterval(-4 * 60 * 60), value: 200),
            PerformancePoint(time: now.addingTimeInterval(-3 * 60 * 60), value: 450),
            PerformancePoint(time: now.addingTimeInterval(-2 * 60 * 60), value: 700),
            PerformancePoint(time: now.addingTimeInterval(-60 * 60), value: 900),
            PerformancePoint(time: now.addingTimeInterval(-30 * 60), value: 1100),
            PerformancePoint(time: now, value: 1486)
        ]
    }
    
    private var statsGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
            statCard(
                title: "Total P&L",
                subtitle: "$1,486",
                icon: "dollarsign.circle",
                iconColor: .profit
            )
            statCard(
                title: "Win Rate",
                subtitle: "66%",
                icon: "target",
                iconColor: .blue
            )
            statCard(
                title: "Total Trades",
                subtitle: "6",
                icon: "chart.bar",
                iconColor: .purple
            )
            statCard(
                title: "Total Fees",
                subtitle: "$12",
                icon: "creditcard",
                iconColor: .red
            )
        }
    }
    
    private func statCard(title: String, subtitle: String, icon: String, iconColor: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(iconColor)
                    .padding(8)
                    .background(iconColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                Spacer()
            }
            Text(title)
                .font(AppFont.caption)
                .foregroundStyle(.secondary)
            Text(subtitle)
                .font(AppFont.subtitle)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var performanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(AppFont.subtitle)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
                .frame(height: 180)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                .overlay {
                    Chart(performanceData) { point in
                        AreaMark(
                            x: .value("Time", point.time),
                            y: .value("P&L", point.value)
                        )
                        .interpolationMethod(.monotone)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.35), Color.appPrimary.opacity(0.05)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        
                        LineMark(
                            x: .value("Time", point.time),
                            y: .value("P&L", point.value)
                        )
                        .interpolationMethod(.monotone)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .foregroundStyle(Color.appPrimary)
                    }
                    .chartXAxis(.hidden)
                    .chartYAxis(.hidden)
                    .padding(.horizontal, 12)
                }
        }
    }
    
    private var tradeQualitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Trade Quality")
                .font(AppFont.subtitle)
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
                .frame(height: 180)
                .overlay {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Wins: 4")
                                .font(AppFont.body)
                                .foregroundStyle(Color.profit)
                            Text("Losses: 2")
                                .font(AppFont.body)
                                .foregroundStyle(Color.loss)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .trim(from: 0, to: 1)
                                .stroke(Color.red.opacity(0.18), lineWidth: 10)
                            Circle()
                                .trim(from: 0, to: 4.0 / 6.0)
                                .stroke(Color.profit, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            VStack(spacing: 2) {
                                Text("4/6")
                                    .font(.headline)
                                Text("Wins")
                                    .font(AppFont.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: 80, height: 80)
                    }
                    .padding(.vertical,12)
                }
        }
    }
    
    private var todaysTradesSection: some View {
        let todaysTrades = tradeViewModel.trades.filter { Calendar.current.isDateInToday($0.date) }
        
        return VStack(alignment: .leading, spacing: 12) {
            Text("Today's Trades")
                .font(AppFont.subtitle)
            
            VStack(alignment: .leading, spacing: 0) {
                if todaysTrades.isEmpty {
                    Text("No trades for today")
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                        .padding()
                } else {
                    ForEach(todaysTrades) { trade in
                        NavigationLink {
                            TradeDetailView(trade: trade)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(trade.symbol)
                                        .font(AppFont.body)
                                    Text(trade.strategy)
                                        .font(AppFont.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(String(format: "%.0f$", trade.pnl))
                                    .font(AppFont.body)
                                    .foregroundStyle(trade.pnl >= 0 ? Color.profit : Color.loss)
                            }
                            .padding(.vertical, 16)
                        }
                        
                        if trade.id != todaysTrades.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }

    private var marketPricesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Market Prices")
                    .font(AppFont.subtitle)
                Spacer()
                if !marketViewModel.exchange.isEmpty {
                    Text(marketViewModel.exchange)
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    Task { await marketViewModel.reload() }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 13, weight: .semibold))
                        .padding(8)
                        .background(Color.appPrimary.opacity(0.12))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 0) {
                if marketViewModel.isLoading && marketViewModel.items.isEmpty {
                    HStack {
                        ProgressView()
                        Text("Loading prices...")
                            .font(AppFont.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                } else if let errorMessage = marketViewModel.errorMessage, marketViewModel.items.isEmpty {
                    Text(errorMessage)
                        .font(AppFont.caption)
                        .foregroundStyle(.lossRed)
                        .padding()
                } else {
                    let exchange = marketViewModel.exchange.isEmpty ? "bingx" : marketViewModel.exchange
                    ForEach(Array(marketViewModel.items.prefix(6))) { item in
                        NavigationLink {
                            MarketOHLCVChartView(exchange: exchange, symbol: item.symbol)
                        } label: {
                            marketPriceRow(item)
                        }
                        .buttonStyle(.plain)

                        if item.id != marketViewModel.items.prefix(6).last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.card)
            )
            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)

            if marketViewModel.total > 0 {
                Text("Total symbols: \(marketViewModel.total)")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func marketPriceRow(_ item: MarketPrice) -> some View {
        HStack {
            Text(item.symbol)
                .font(AppFont.body)

            Spacer()

            Text(String(format: "$%.2f", item.price))
                .font(AppFont.body)

            Text(String(format: "%.2f%%", item.change24hPct))
                .font(AppFont.caption)
                .foregroundStyle(item.change24hPct >= 0 ? Color.profit : Color.loss)
                .frame(width: 72, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    let container = AppContainer()
    DashboardView(showMenu: .constant(true))
        .environmentObject(TradeViewModel(
            fetchTrades: container.fetchTradesUseCase,
            addTrade: container.addTradeUseCase
        ))
        .environmentObject(
            MarketViewModel(
                fetchMarketPrices: container.fetchMarketPricesUseCase,
                fetchMarketOHLCV: container.fetchMarketOHLCVUseCase
            )
        )
}
