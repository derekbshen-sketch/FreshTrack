//
//  ReceiptHistoryDetailView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import SwiftUI

struct ReceiptHistoryDetailView: View {
    @EnvironmentObject var settingsState: SettingsState
    let entry: ReceiptHistoryItem

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {

                    if let data = entry.imageData,
                       let image = UIImage(data: data) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    Text("Items")
                        .font(.title2)
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                        .padding(.horizontal)

                    ForEach(entry.items) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.headline)
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                            Text("Qty: \(item.quantity) \(item.unit.rawValue)")
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))

                            Text("Category: \(item.category)")
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))

                            Text("Expires: \(formatted(item.expirationDate))")
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))
                        }
                        .padding()
                        .background(Color(.systemGray6).opacity(0.4))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("Receipt Details")
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}

