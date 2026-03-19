//
//  CalendarView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/18/26.
//

import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var tradeViewModel: TradeViewModel

    @State private var displayedMonth: Date = Date.now
    @State private var selectedDate: Date = Date.now

    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                monthHeader
                monthGrid
                tradesForSelectedDay
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(Color.backgroundColor.ignoresSafeArea())
        .onAppear {
            syncSelectionWithDisplayedMonth()
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var monthHeader: some View {
        HStack {
            Text(displayedMonth, format: .dateTime.month(.wide).year())
                .font(.system(size: 40, weight: .bold, design: .rounded))

            Spacer()

            HStack(spacing: 12) {
                monthButton(systemImage: "chevron.left", action: previousMonth)
                monthButton(systemImage: "chevron.right", action: nextMonth)
            }
        }
    }

    private func monthButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.highlightBlue)
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
    }

    private var monthGrid: some View {
        let days = monthDays

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 14) {
            ForEach(days.indices, id: \.self) { index in
                let day = days[index]
                if let day {
                    dayCell(for: day)
                } else {
                    Color.clear
                        .frame(height: 38)
                }
            }
        }
    }

    private func dayCell(for date: Date) -> some View {
        let day = calendar.component(.day, from: date)
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)

        return Button {
            selectedDate = date
        } label: {
            Text("\(day)")
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isSelected ? .white : .primary)
                .frame(width: 38, height: 38)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(isSelected ? .highlightBlue : .clear)
                )
        }
        .buttonStyle(.plain)
    }

    private var monthDays: [Date?] {
        guard
            let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
            let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
            let lastDayInMonth = calendar.date(byAdding: DateComponents(day: -1), to: monthInterval.end),
            let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: lastDayInMonth)
        else {
            return []
        }

        let visibleInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        let dayCount = calendar.dateComponents([.day], from: visibleInterval.start, to: visibleInterval.end).day ?? 0

        return (0..<dayCount).map { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: visibleInterval.start) else {
                return nil
            }

            if calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month) {
                return date
            }

            return nil
        }
    }

    private var tradesForSelectedDay: some View {
        let dayTrades = tradeViewModel.trades
            .filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
            .sorted { $0.date > $1.date }

        return VStack(spacing: 10) {
            ForEach(dayTrades) { trade in
                tradeRow(trade)
            }

            if dayTrades.isEmpty {
                ContentUnavailableView("No trades", systemImage: "calendar")
                    .frame(maxWidth: .infinity)
                    .padding(.top, 28)
            }
        }
    }

    private func tradeRow(_ trade: Trade) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(trade.symbol)
                    .font(.system(size: 19, weight: .bold))

                Text(trade.side == .long ? "Buy" : "Sell")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(pnlText(for: trade.pnl))
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(trade.pnl >= 0 ? Color.profit : Color.loss)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.cardBackground)
        )
    }

    private func pnlText(for value: Double) -> String {
        let absolute = abs(value).formatted(.number.precision(.fractionLength(2)))
        return value >= 0 ? "$ \(absolute)" : "-$ \(absolute)"
    }

    private func previousMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else {
            return
        }
        displayedMonth = newDate
        syncSelectionWithDisplayedMonth()
    }

    private func nextMonth() {
        guard let newDate = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else {
            return
        }
        displayedMonth = newDate
        syncSelectionWithDisplayedMonth()
    }

    private func syncSelectionWithDisplayedMonth() {
        if !calendar.isDate(selectedDate, equalTo: displayedMonth, toGranularity: .month) {
            if let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: displayedMonth)) {
                selectedDate = firstDay
            }
        }
    }
}

#Preview {
    let container = AppContainer()

    return NavigationStack {
        CalendarView()
            .environmentObject(
                TradeViewModel(
                    fetchTrades: container.fetchTradesUseCase,
                    addTrade: container.addTradeUseCase
                )
            )
    }
}
