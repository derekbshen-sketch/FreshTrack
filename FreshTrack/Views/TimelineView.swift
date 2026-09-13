//
//  TimelineView.swift
//  FreshTrack
//

import SwiftUI

struct TimelineView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState

    var sortedItems: [Item] {
        itemState.items.sorted { $0.expirationDate < $1.expirationDate }
    }

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(spacing: 16) {

                Text("Timeline")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top, 20)

                if sortedItems.isEmpty {
                    Text("No items added yet.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding(.top, 40)
                } else {
                    List {
                        ForEach(sortedItems) { item in
                            NavigationLink {
                                EditItemView(item: item)
                            } label: {
                                TimelineRow(item: item)
                                    .environmentObject(settingsState)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listStyle(.insetGrouped)
                }

                Spacer()
            }
        }
        .navigationTitle("Timeline")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TimelineRow: View {
    let item: Item
    @EnvironmentObject var settingsState: SettingsState

    var expirationColor: Color {
        if item.isExpired {
            return .red
        } else if item.daysUntilExpiration <= 3 {
            return .orange
        } else {
            return .green
        }
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text("\(item.quantity.cleanString()) \(item.quantityType)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Expires: \(item.formattedExpiration)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Circle()
                .fill(expirationColor)
                .frame(width: 14, height: 14)
        }
        .padding(.vertical, 6)
    }
}

extension Double {
    func cleanString() -> String {
        self == floor(self) ? String(format: "%.0f", self) : String(self)
    }
}
