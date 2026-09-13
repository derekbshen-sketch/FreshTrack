//
//  AddAlertView.swift
//  FreshTrack
//

import SwiftUI
import Combine

struct AddAlertView: View {
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var settingsState: SettingsState
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var date = Date()
    @State private var time = Date()

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            NavigationView {
                VStack(spacing: 20) {

                    Text("Add Alert")
                        .font(.largeTitle)
                        .foregroundColor(
                            themedAccent(
                                for: settingsState.selectedTheme,
                                accent: settingsState.accentColor
                            )
                        )

                    TextField("Alert Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)

                    DatePicker("Alert Date", selection: $date, displayedComponents: .date)
                        .padding(.horizontal)

                    DatePicker("Alert Time", selection: $time, displayedComponents: .hourAndMinute)
                        .padding(.horizontal)

                    Button("Add") {
                        alertState.addManualAlert(
                            title: title,
                            date: date,
                            time: time
                        )
                        dismiss()
                    }
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )

                    Spacer()
                }
            }
        }
    }
}
