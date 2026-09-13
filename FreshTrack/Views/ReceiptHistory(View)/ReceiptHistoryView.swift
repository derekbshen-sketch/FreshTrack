//
//  ReceiptHistoryView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import SwiftUI

struct ReceiptHistoryView: View {
    @EnvironmentObject var receiptHistory: ReceiptHistoryState
    @EnvironmentObject var settingsState: SettingsState

    @State private var showClearWarning = false

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack {
                if receiptHistory.history.isEmpty {
                    Text("No receipt history yet.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding()
                } else {
                    List {
                        ForEach(receiptHistory.history) { entry in
                            NavigationLink {
                                ReceiptHistoryDetailView(entry: entry)
                                    .environmentObject(settingsState)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text("Scanned: \(formatted(entry.dateScanned))")
                                        .font(.headline)
                                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                                    Text("\(entry.items.count) items")
                                        .foregroundColor(
                                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                                        )
                                }
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
                .alert("Clear All Receipt History?",
                       isPresented: $showClearWarning) {
                    Button("Delete All", role: .destructive) {
                        receiptHistory.clearHistory()
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("This action cannot be undone.")
                }
            }
        }
        .navigationTitle("Receipt History")
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
