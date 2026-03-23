//
//  AddTradeView.swift
//  TradingDiary
//
//  Created by dnkdo on 3/13/26.
//

import SwiftUI

struct AddTradeView: View {

    private enum Field: Hashable {
        case symbol
        case quantity
        case entry
        case exit
    }

    private enum TradeSide: String, CaseIterable, Identifiable {
        case buy = "BUY"
        case sell = "SELL"

        var id: String { rawValue }

        var asDomainSide: Trade.Side {
            switch self {
            case .buy:
                return .long
            case .sell:
                return .short
            }
        }
    }

    @EnvironmentObject private var vm: TradeViewModel

    @State private var symbol = ""
    @State private var selectedSide: TradeSide = .buy
    @State private var quantity = "1"
    @State private var entry = ""
    @State private var exit = ""
    @State private var openedAt = Date()
    @State private var includeClosedAt = true
    @State private var closedAt = Date()
    @State private var notes = ""

    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isSaving = false

    @FocusState private var focusedField: Field?

    private var isInputValid: Bool {
        !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && (Double(quantity) ?? 0) > 0
            && (Double(entry) ?? 0) > 0
            && (Double(exit) ?? 0) > 0
    }

    var body: some View {
        Form {
            Section("Trade") {
                TextField("Symbol", text: $symbol)
                    .textInputAutocapitalization(.characters)
                    .autocorrectionDisabled()
                    .focused($focusedField, equals: .symbol)

                Picker("Side", selection: $selectedSide) {
                    ForEach(TradeSide.allCases) { side in
                        Text(side.rawValue).tag(side)
                    }
                }
                .pickerStyle(.segmented)

                TextField("Quantity", text: $quantity)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .quantity)

                TextField("Entry Price", text: $entry)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .entry)

                TextField("Exit Price", text: $exit)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .exit)
            }

            Section("Timing") {
                DatePicker("Opened At", selection: $openedAt)

                Toggle("Include Closed At", isOn: $includeClosedAt.animation())

                if includeClosedAt {
                    DatePicker("Closed At", selection: $closedAt, in: openedAt...)
                }
            }

            Section("Notes") {
                TextEditor(text: $notes)
                    .frame(minHeight: 120)
            }

            Section {
                Button {
                    saveTrade()
                } label: {
                    Text(isSaving ? "Saving..." : "Save Trade")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .disabled(!isInputValid || isSaving)
            }
        }
        .navigationTitle("Add Trade")
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
            }
        }
        .alert("Add Trade", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func saveTrade() {
        let normalizedSymbol = symbol
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .uppercased()

        guard let parsedQuantity = Double(quantity), parsedQuantity > 0 else {
            showValidationAlert("Quantity must be greater than 0.")
            return
        }

        guard let parsedEntry = Double(entry), parsedEntry > 0 else {
            showValidationAlert("Entry price must be greater than 0.")
            return
        }

        guard let parsedExit = Double(exit), parsedExit > 0 else {
            showValidationAlert("Exit price must be greater than 0.")
            return
        }

        let safeClosedAt = includeClosedAt ? closedAt : nil
        let normalizedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        isSaving = true
        Task {
            let didSave = await vm.addTrade(
                symbol: normalizedSymbol,
                side: selectedSide.asDomainSide,
                quantity: parsedQuantity,
                entry: parsedEntry,
                exit: parsedExit,
                openedAt: openedAt,
                closedAt: safeClosedAt,
                notes: normalizedNotes,
                strategy: "Manual"
            )

            isSaving = false
            if didSave {
                showValidationAlert("Trade saved successfully.")
                resetForm()
            } else {
                showValidationAlert(vm.errorMessage ?? "Failed to save trade.")
            }
        }
    }

    private func resetForm() {
        symbol = ""
        selectedSide = .buy
        quantity = "1"
        entry = ""
        exit = ""
        openedAt = Date()
        closedAt = Date()
        includeClosedAt = true
        notes = ""
        focusedField = nil
    }

    private func showValidationAlert(_ message: String) {
        alertMessage = message
        showAlert = true
    }
}

#Preview {
    let container = AppContainer()
    return AddTradeView()
        .environmentObject(
            TradeViewModel(
                fetchTrades: container.fetchTradesUseCase,
                addTrade: container.addTradeUseCase
            )
        )
}
