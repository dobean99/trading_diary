//
//  StatisticsView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//

import SwiftUI
import Charts

struct StatisticsView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel
    @State private var selectedRange: StatisticsRange = .week

    private let chartBlue = Color(red: 0.18, green: 0.48, blue: 1.0)
    private let controlBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    private let cardBackground = Color(red: 0.96, green: 0.96, blue: 0.98)
    private let neutralText = Color(red: 0.55, green: 0.56, blue: 0.62)
    private let tradePurple = Color(red: 0.61, green: 0.37, blue: 0.94)

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                rangePicker
                statsGrid
                equityChartCard
                tradeOutcomeSummary
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 34)
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
    }

    private var filteredTrades: [Trade] {
        let now = Date()
        return tradeViewModel.trades
            .filter { selectedRange.contains($0.date, now: now, calendar: .current) }
            .sorted { $0.date < $1.date }
    }

    private var winningTrades: [Trade] {
        filteredTrades.filter { $0.pnl >= 0 }
    }

    private var losingTrades: [Trade] {
        filteredTrades.filter { $0.pnl < 0 }
    }

    private var totalPnL: Double {
        filteredTrades.reduce(0) { $0 + $1.pnl }
    }

    private var winRate: Int {
        guard !filteredTrades.isEmpty else { return 0 }

        let percentage = (Double(winningTrades.count) / Double(filteredTrades.count)) * 100
        return Int(percentage.rounded())
    }

    private var averageRR: Double {
        guard !winningTrades.isEmpty, !losingTrades.isEmpty else { return 0 }

        let averageWin = winningTrades.map(\.pnl).reduce(0, +) / Double(winningTrades.count)
        let averageLoss = losingTrades.map { abs($0.pnl) }.reduce(0, +) / Double(losingTrades.count)

        guard averageLoss > 0 else { return 0 }
        return averageWin / averageLoss
    }

    private var equityPoints: [EquityPoint] {
        guard !filteredTrades.isEmpty else {
            return [
                EquityPoint(index: 0, value: 0),
                EquityPoint(index: 1, value: 0)
            ]
        }

        var runningPnL = 0.0
        var points = [EquityPoint(index: 0, value: 0)]

        for (offset, trade) in filteredTrades.enumerated() {
            runningPnL += trade.pnl
            points.append(EquityPoint(index: offset + 1, value: runningPnL))
        }

        return points
    }

    private var chartDomain: ClosedRange<Double> {
        let values = equityPoints.map(\.value)
        let minValue = min(values.min() ?? 0, 0)
        let maxValue = max(values.max() ?? 0, 0)

        if minValue == maxValue {
            return (minValue - 100)...(maxValue + 100)
        }

        let padding = max((maxValue - minValue) * 0.18, 80)
        return (minValue - padding)...(maxValue + padding)
    }

    private var rangePicker: some View {
        HStack(spacing: 6) {
            ForEach(StatisticsRange.allCases) { range in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedRange = range
                    }
                } label: {
                    Text(range.rawValue)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(selectedRange == range ? chartBlue : neutralText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(selectedRange == range ? chartBlue.opacity(0.14) : .clear)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(controlBackground)
        )
    }

    private var statsGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.flexible(), spacing: 14), count: 2),
            spacing: 14
        ) {
            statisticCard(
                title: "Total P&L",
                value: currencyText(totalPnL),
                icon: "dollarsign.circle.fill",
                tint: totalPnL >= 0 ? .profit : .loss
            )

            statisticCard(
                title: "Win Rate",
                value: "\(winRate)%",
                icon: "chart.bar.fill",
                tint: chartBlue
            )

            statisticCard(
                title: "Trades",
                value: "\(filteredTrades.count)",
                icon: "number.circle.fill",
                tint: tradePurple
            )

            statisticCard(
                title: "Avg RR",
                value: rrText(averageRR),
                icon: "arrow.left.and.right.circle.fill",
                tint: Color.orange
            )
        }
    }

    private func statisticCard(title: String, value: String, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(neutralText)

                Text(value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(tint)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(cardBackground)
        )
    }

    private var equityChartCard: some View {
        VStack(spacing: 0) {
            Chart {
                ForEach(equityPoints) { point in
                    LineMark(
                        x: .value("Trade", point.index),
                        y: .value("Equity", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .foregroundStyle(chartBlue)

                    if point.index == equityPoints.last?.index {
                        PointMark(
                            x: .value("Trade", point.index),
                            y: .value("Equity", point.value)
                        )
                        .foregroundStyle(chartBlue)
                        .symbolSize(50)
                    }
                }
            }
            .chartLegend(.hidden)
            .chartXScale(domain: 0...max(1, equityPoints.count - 1))
            .chartYScale(domain: chartDomain)
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.8, dash: [2, 3]))
                        .foregroundStyle(Color.secondary.opacity(0.2))
                    AxisValueLabel {
                        if let index = value.as(Int.self) {
                            Text("\(index)")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(neutralText)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .trailing, values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine(stroke: StrokeStyle(lineWidth: 0.8))
                        .foregroundStyle(Color.secondary.opacity(0.14))
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text(axisText(amount))
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(neutralText)
                        }
                    }
                }
            }
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color.white)
            }
            .frame(height: 215)
            .padding(.horizontal, 10)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.04), lineWidth: 1)
        )
    }

    private var tradeOutcomeSummary: some View {
        HStack(spacing: 42) {
            outcomeColumn(
                label: "Winning Trades",
                value: winningTrades.count,
                icon: "arrow.up.right",
                tint: .profit
            )

            outcomeColumn(
                label: "Losing Trades",
                value: losingTrades.count,
                icon: "arrow.down.right",
                tint: .loss
            )

            Spacer(minLength: 0)
        }
        .padding(.top, 8)
    }

    private func outcomeColumn(label: String, value: Int, icon: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)

            Text(label)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(neutralText)

            Text("\(value)")
                .font(.system(size: 38, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
        }
    }

    private func currencyText(_ value: Double) -> String {
        let sign = value < 0 ? "-" : ""
        return "\(sign)$\(abs(value).formatted(.number.grouping(.never).precision(.fractionLength(0))))"
    }

    private func rrText(_ value: Double) -> String {
        guard value > 0 else { return "0.00R" }
        return "\(value.formatted(.number.precision(.fractionLength(2))))R"
    }

    private func axisText(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0)))
    }
}

private extension StatisticsView {
    enum StatisticsRange: String, CaseIterable, Identifiable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
        case all = "All"

        var id: String { rawValue }

        func contains(_ date: Date, now: Date, calendar: Calendar) -> Bool {
            switch self {
            case .day:
                return calendar.isDate(date, inSameDayAs: now)
            case .week:
                guard let startDate = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: now)) else {
                    return true
                }
                return date >= startDate && date <= now
            case .month:
                guard let startDate = calendar.date(byAdding: .day, value: -29, to: calendar.startOfDay(for: now)) else {
                    return true
                }
                return date >= startDate && date <= now
            case .year:
                guard let startDate = calendar.date(byAdding: .year, value: -1, to: calendar.startOfDay(for: now)) else {
                    return true
                }
                return date >= startDate && date <= now
            case .all:
                return true
            }
        }
    }

    struct EquityPoint: Identifiable {
        let index: Int
        let value: Double

        var id: Int { index }
    }
}

#Preview {
    let container = AppContainer()

    return NavigationStack {
        StatisticsView()
            .environmentObject(
                TradeViewModel(
                    fetchTrades: container.fetchTradesUseCase,
                    addTrade: container.addTradeUseCase
                )
            )
    }
}
