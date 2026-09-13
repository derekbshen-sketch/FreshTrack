//
//  FreshTrackApp.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/27/26.
//

import SwiftUI

@main
struct FreshTrackApp: App {
    @StateObject var itemState = ItemState()
    @StateObject var alertState = AlertState()
    @StateObject var settingsState = SettingsState()
    @StateObject var groceryListState = GroceryListState()
    @StateObject private var receiptHistory = ReceiptHistoryState()
    @StateObject var groceryListHistory = GroceryListHistoryState()
    @StateObject var itemStorageHistory = ItemStorageHistoryState()
    @StateObject var expiredItemHistory = ExpiredItemHistoryState()
    @StateObject var statisticsState = StatisticsState()
    @StateObject var budgetState = BudgetState()

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(itemState)
                .environmentObject(alertState)
                .environmentObject(settingsState)
                .environmentObject(groceryListState)
                .environmentObject(receiptHistory)
                .environmentObject(groceryListHistory)
                .environmentObject(itemStorageHistory)
                .environmentObject(expiredItemHistory)
                .environmentObject(statisticsState)
                .environmentObject(budgetState)
                .background(appBackground(for: settingsState.selectedTheme))
                        .ignoresSafeArea()
            
            
                .onAppear {
                    groceryListState.attachAlertState(alertState)
                }
        }
    }
}
