//
//  ExpiredItemHistoryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI

struct ExpiredItemHistoryView: View {
    @EnvironmentObject var expiredItemHistory: ExpiredItemHistoryState
    @EnvironmentObject var settingsState: SettingsState
    @State private var showClearWarning = false

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack {
                if expiredItemHistory.history.isEmpty {
                    Text("No expired item history.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding()
                } else {
                    List {
                        ForEach(expiredItemHistory.history) { entry in
                            VStack(alignment: .leading) {
                                Text(entry.item.name)
                                    .font(.headline)
                                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                                Text("Expired: \(formatted(entry.dateExpired))")
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
                .alert("Clear All Expired Item History?",
                       isPresented: $showClearWarning) {
                    Button("Delete All", role: .destructive) {
                        expiredItemHistory.clearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Expired Item History")
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
