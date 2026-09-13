//
//  FridgeView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//

import SwiftUI
import Foundation
import Combine

struct FridgeView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var alertState: AlertState

    @State private var selectedItem: Item?

    var fridgeItems: [Item] {
        itemState.items.filter { $0.category.lowercased() == "fridge" }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Fridge")
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

                    // MAIN BODY — stainless steel gradient
                    RoundedRectangle(cornerRadius: 28)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(.systemGray5),
                                    Color(.systemGray4),
                                    Color(.systemGray3),
                                    Color(.systemGray5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 3)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)

                    // DOOR SEPARATION LINE
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 4)
                        .offset(y: -geo.size.height * 0.15)

                    // HANDLE
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.7))
                        .frame(width: 14, height: geo.size.height * 0.55)
                        .offset(x: geo.size.width * 0.38, y: -geo.size.height * 0.05)
                        .shadow(radius: 4)

                    // SHELVES
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.3))
                            .frame(height: 4)
                            .shadow(radius: 2)
                            .offset(y: -geo.size.height * 0.25 + CGFloat(i) * (geo.size.height * 0.18))
                    }

                    // ITEMS WITH PERSISTENT POSITIONS + DRAG
                    ForEach(fridgeItems, id: \.id) { item in
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
            .frame(height: 330)

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
