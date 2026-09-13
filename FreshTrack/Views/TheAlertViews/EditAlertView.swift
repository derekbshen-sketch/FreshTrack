//
//  EditAlertView.swift
//  FreshTrack
//

import SwiftUI
import Combine

struct EditAlertView: View {
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var settingsState: SettingsState
    @Environment(\.dismiss) var dismiss

    let alert: AlertItem

    @State private var title: String
    @State private var date: Date
    @State private var time: Date

    init(alert: AlertItem) {
        self.alert = alert
        _title = State(initialValue: alert.title)
        _date = State(initialValue: alert.alertDate)
        _time = State(initialValue: alert.alertTime)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {

                Text("Edit Alert")
                    .font(.largeTitle)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )

                if let exp = alert.expirationDate {
                    Text("Expires on \(formatted(exp))")
                        .font(.caption)
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                }

                TextField("Alert Title", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                DatePicker("Alert Date", selection: $date, displayedComponents: .date)
                    .padding(.horizontal)

                DatePicker("Alert Time", selection: $time, displayedComponents: .hourAndMinute)
                    .padding(.horizontal)

                Button("Save Changes") {
                    alertState.updateAlert(
                        alert,
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

    func formatted(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f.string(from: date)
    }
}
