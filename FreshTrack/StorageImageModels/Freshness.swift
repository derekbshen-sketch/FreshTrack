//
//  Freshness.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/4/26.
//
import SwiftUI
import Foundation

struct FreshnessKey: View {
    @EnvironmentObject var settingsState: SettingsState

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            // Themed Header
            Text("Freshness Key")
                .font(.headline)
                .foregroundColor(
                    themedAccent(
                        for: settingsState.selectedTheme,
                        accent: settingsState.accentColor
                    )
                )

            // Fresh (Green)
            HStack {
                Color.green
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)

                Text("Fresh (6+ days left)")
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )
            }
//Okay Yellow
            HStack {
                Color.yellow
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)

                Text("Okay (3–5 days left)")
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )
            }

            // Expiring Soon (Orange)
            HStack {
                Color.orange
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)

                Text("Expiring Soon (0–2 days left)")
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )
            }

            // ⭐ Expired (Red)
            HStack {
                Color.red
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)

                Text("Expired")
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )
            }
        }
        .padding(.horizontal)
    }
}
