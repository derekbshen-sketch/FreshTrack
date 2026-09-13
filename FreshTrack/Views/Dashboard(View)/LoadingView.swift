//
//  LoadingView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/6/26.
//

import SwiftUI

struct LoadingView: View {
    @EnvironmentObject var settingsState: SettingsState
    @State private var isAnimating = false

    var body: some View {
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // Animated spinner
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    .onAppear {
                        isAnimating = true
                    }

                Text("Loading…")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )
            }
        }
    }
}
