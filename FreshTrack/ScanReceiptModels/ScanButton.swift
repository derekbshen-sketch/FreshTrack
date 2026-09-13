//
//  ScanButton.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/30/26.
//

import SwiftUI

struct ScanButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color)
        .cornerRadius(16)
    }
}

