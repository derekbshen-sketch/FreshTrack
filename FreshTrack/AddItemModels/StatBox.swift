//
//  StatBox.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/27/26.
//
import SwiftUI

struct StatBox: View {
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(width: 100, height: 80)
        .background(color)
        .cornerRadius(12)
    }
}

