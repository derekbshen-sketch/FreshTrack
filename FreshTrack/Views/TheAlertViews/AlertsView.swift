//
//  AlertsView.swift
//  FreshTrack
//

import SwiftUI
import Combine

struct AlertsView: View {
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var settingsState: SettingsState

    @State private var showAddAlert = false
    @State private var editingAlert: AlertItem? = nil

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Text("Alerts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top, 20)

                Button {
                    showAddAlert = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Add Alert")
                    }
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        if alertState.alerts.isEmpty {
                            Text("No alerts yet.")
                                .foregroundColor(
                                    themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                                )
                        } else {
                            ForEach(alertState.alerts) { alert in
                                VStack(alignment: .leading, spacing: 6) {

                                    Text(alert.title)
                                        .font(.headline)
                                        .foregroundColor(
                                            themedTextColor(for: settingsState.selectedTheme)
                                        )

                                    Text("Alert scheduled for \(formatted(alert.alertTime))")
                                        .font(.caption2)
                                        .foregroundColor(.gray.opacity(0.7))

                                    HStack {
                                        Button("Edit") {
                                            editingAlert = alert
                                        }
                                        .foregroundColor(.blue)

                                        Button("Delete") {
                                            alertState.deleteAlert(alert)
                                        }
                                        .foregroundColor(.red)
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.4))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
        .sheet(isPresented: $showAddAlert) {
            AddAlertView()
                .environmentObject(alertState)
                .environmentObject(settingsState)
        }
        .sheet(item: $editingAlert) { alert in
            EditAlertView(alert: alert)
                .environmentObject(alertState)
                .environmentObject(settingsState)
        }
    }

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: date)
    }
}
