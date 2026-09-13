//
//  FreezerView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//

import Foundation
import SwiftUI

struct FreezerView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState

    @State private var selectedItem: Item?

    var freezerItems: [Item] {
        itemState.items.filter { $0.category.lowercased() == "freezer" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Freezer")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(
                    themedAccent(
                        for: settingsState.selectedTheme,
                        accent: settingsState.accentColor
                    )
                )

            GeometryReader { geo in
                ZStack {

                    // FREEZER BODY
                    RoundedRectangle(cornerRadius: 22)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray4),
                                    Color(.systemGray3)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)

                    // HANDLE
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: geo.size.width * 0.45, height: 14)
                        .offset(y: -geo.size.height * 0.32)
                        .shadow(radius: 4)

                    // FROST EFFECT
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color.white.opacity(0.08))
                        .blur(radius: 3)

                    // SHELVES
                    ForEach(0..<2) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 3)
                            .offset(y: -geo.size.height * 0.2 + CGFloat(i) * (geo.size.height * 0.22))
                    }

                    // ITEMS WITH PERSISTENT POSITIONS + DRAG
                    ForEach(freezerItems, id: \.id) { item in
                        let x = item.posX * geo.size.width
                        let y = item.posY * geo.size.height

                        FoodTile(item: item)
                            .position(x: x, y: y)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let newX = value.location.x / geo.size.width
                                        let newY = value.location.y / geo.size.height

                                        itemState.updatePosition(
                                            item,
                                            x: min(max(newX, 0.05), 0.95),
                                            y: min(max(newY, 0.05), 0.95)
                                        )
                                    }
                            )
                            .onTapGesture {
                                selectedItem = item
                            }
                    }
                }
            }
            .frame(height: 220)

            // INLINE EDITOR
            if let editing = selectedItem {
                ItemInlineEditor(
                    item: editing,
                    onDelete: {
                        itemState.removeItem(editing, alertState: alertState)
                        selectedItem = nil
                    },
                    onSave: { updatedName, updatedQty, updatedUnit, updatedCategory, updatedExpiration in

                        // Update name, quantity, unit
                        itemState.updateItem(
                            editing,
                            name: updatedName,
                            quantity: updatedQty,
                            unit: updatedUnit
                        )

                        // Update category, expiration, cost
                        if let index = itemState.items.firstIndex(where: { $0.id == editing.id }) {
                            itemState.items[index].category = updatedCategory
                            itemState.items[index].expirationDate = updatedExpiration
                        }

                        selectedItem = nil
                    }
                )
                .environmentObject(settingsState)
                .padding(.top, 12)
            }
        }
        .padding(.horizontal)
    }
}
