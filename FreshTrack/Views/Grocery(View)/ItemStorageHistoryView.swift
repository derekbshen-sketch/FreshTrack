//
//  ItemStorageHistoryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI

struct ItemStorageHistoryView: View {
    @EnvironmentObject var itemStorageHistory: ItemStorageHistoryState
    @EnvironmentObject var settingsState: SettingsState

    @State private var showClearWarning = false

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack {
                if itemStorageHistory.history.isEmpty {
                    Text("No stored item history.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding()
                } else {
                    List {
                        ForEach(itemStorageHistory.history) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.item.name)
                                    .font(.headline)
                                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                                Text("Stored: \(formatted(entry.dateStored))")
                                    .foregroundColor(
                                        themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                                    )
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }

                Button("Clear All History") {
                    showClearWarning = true
                }
                .foregroundColor(.red)
                .padding()
                .alert("Clear All Stored Item History?",
                       isPresented: $showClearWarning) {
                    Button("Delete All", role: .destructive) {
                        itemStorageHistory.clearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Stored Item History")
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
