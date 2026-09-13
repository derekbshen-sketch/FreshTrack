//
//  FoodTile.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//
import Foundation
import SwiftUI

struct FoodTile: View {
    let item: Item

    var body: some View {
        VStack(spacing: 2) {
            if let data = item.imageData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Text(item.name)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .padding(6)
        .background(freshnessColor(for: item))
        .cornerRadius(8)
        .shadow(radius: 3)
    }
}
