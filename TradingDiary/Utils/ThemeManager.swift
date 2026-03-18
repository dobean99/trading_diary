//
//  ThemeManager.swift
//  TradingDiary
//
//  Created by dnkdo on 3/16/26.
//


import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {

    @Published var isDarkMode: Bool = false

    var colorScheme: ColorScheme? {
        isDarkMode ? .dark : .light
    }

    func toggleTheme() {
        isDarkMode.toggle()
    }
}