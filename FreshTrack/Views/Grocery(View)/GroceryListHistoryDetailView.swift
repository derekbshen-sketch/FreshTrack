//
//  GroceryListHistoryDetailView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI

struct GroceryListHistoryDetailView: View {
    @EnvironmentObject var settingsState: SettingsState
    let entry: GroceryListHistoryItem

    var body: some View {

        // ⭐ FULL SCREEN THEME BACKGROUND
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            List {
                ForEach(entry.items, id: \.self) { name in
                    Text(name)
                        .font(.headline)
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        }
        .navigationTitle("List Details")
    }
}
