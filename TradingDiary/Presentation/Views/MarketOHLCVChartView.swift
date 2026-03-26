import SwiftUI
import SwiftTradingView

struct MarketOHLCVChartView: View {
    @EnvironmentObject private var marketViewModel: MarketViewModel
    
    let exchange: String
    let symbol: String
    
    @State private var timeframe: String = "1h"
    @State private var candles: [OHLCVCandle] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let timeframes = ["15m", "1h", "4h", "1d"]
    
    private var tradingViewCandles: [CandleData] {
        candles.map { candle in
            CandleData(
                time: candle.date.timeIntervalSince1970,
                open: candle.open,
                close: candle.close,
                high: candle.high,
                low: candle.low,
                volume: candle.volume
            )
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                header
                timeframePicker
                chartSection
                statsSection
            }
            .padding(16)
        }
        .background(Color.backgroundColor.ignoresSafeArea())
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadChart()
        }
        .onChange(of: timeframe) { _ in
            Task { await loadChart() }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(exchange.uppercased()) • \(symbol)")
                .font(AppFont.subtitle)
            if let latest = candles.last {
                Text(String(format: "Last: $%.4f", latest.close))
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var timeframePicker: some View {
        Picker("Timeframe", selection: $timeframe) {
            ForEach(timeframes, id: \.self) { value in
                Text(value).tag(value)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isLoading && candles.isEmpty {
                HStack {
                    ProgressView()
                    Text("Loading chart...")
                        .font(AppFont.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            } else if let errorMessage, candles.isEmpty {
                Text(errorMessage)
                    .font(AppFont.caption)
                    .foregroundStyle(.lossRed)
                    .padding()
            } else if candles.isEmpty {
                Text("No OHLCV data")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
                    .padding()
            } else {
                TradingView(
                    data: tradingViewCandles,
                    candleWidth: 4...20,
                    candleSpacing: 2,
                    scrollTrailingInset: 24,
                    primaryContent: [
                        Candles(
                            negativeCandleColor: .loss,
                            positiveCandleColor: .profit
                        )
                    ]
                )
                .frame(height: 280)
                .padding(.horizontal, 10)
                .padding(.vertical, 12)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private var statsSection: some View {
        let latest = candles.last
        return VStack(alignment: .leading, spacing: 8) {
            Text("Candle Stats")
                .font(AppFont.subtitle)
            
            if let latest {
                HStack {
                    Text(String(format: "O %.4f", latest.open))
                    Spacer()
                    Text(String(format: "H %.4f", latest.high))
                }
                .font(AppFont.caption)
                .foregroundStyle(.secondary)
                
                HStack {
                    Text(String(format: "L %.4f", latest.low))
                    Spacer()
                    Text(String(format: "C %.4f", latest.close))
                }
                .font(AppFont.caption)
                .foregroundStyle(.secondary)
            } else {
                Text("No data")
                    .font(AppFont.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.card)
        )
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 4)
    }
    
    private func loadChart() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let snapshot = try await marketViewModel.loadOHLCV(
                exchange: exchange,
                symbol: symbol,
                timeframe: timeframe,
                limit: 120
            )
            candles = snapshot.items.sorted { $0.timestamp < $1.timestamp }
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
