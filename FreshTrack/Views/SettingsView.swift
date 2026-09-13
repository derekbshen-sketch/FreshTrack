//
//  SettingsView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/29/26.
//

import SwiftUI
import UIKit

func appBackground(for theme: AppTheme) -> some View {
    switch theme {
    case .light:
        return AnyView(Color(.systemBackground))
    case .dark:
        return AnyView(Color(.black))
    case .aurora:
        return AnyView(LinearGradient(colors: [.purple, .blue, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
    case .sunset:
        return AnyView(LinearGradient(colors: [.orange, .pink, .purple], startPoint: .top, endPoint: .bottom))
    case .ocean:
        return AnyView(LinearGradient(colors: [.blue, .teal], startPoint: .top, endPoint: .bottom))
    case .forest:
        return AnyView(LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing))
    case .minimalWhite:
        return AnyView(Color.white)
    case .highContrast:
        return AnyView(Color.black)
    case .warm:
        return AnyView(LinearGradient(colors: [.red, .orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing))
    case .cool:
        return AnyView(LinearGradient(colors: [.cyan, .blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

func themedTextColor(for theme: AppTheme) -> Color {
    switch theme {
    case .highContrast:
        return .white
    default:
        return .primary   // dynamic system color
    }
}

func themedAccent(for theme: AppTheme, accent: Color) -> Color {
    // Prevent white-on-white
    if accent == .white {
        return Color(white: 0.92)
    }

    // High contrast can still force a strong accent
    if theme == .highContrast {
        return .yellow
    }

    // Otherwise ALWAYS use the user-selected accent color
    return accent
}

struct SettingsView: View {
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var budgetState: BudgetState
    @EnvironmentObject var receiptHistory: ReceiptHistoryState   // ⭐ REQUIRED FOR RESET

    @State private var showResetItemsAlert = false
    @State private var showResetAlertsAlert = false

    static let softWhite = Color(white: 0.92)

    let accentOptions: [Color] = [
        .purple, .blue, .green, .orange, .red,
        .black, SettingsView.softWhite, .brown, .mint, .cyan, .indigo, .yellow
    ]

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(spacing: 20) {

                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top, 20)

                Form {

                    Section(header: Text("Theme")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        Picker("Theme", selection: $settingsState.selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(themeDisplayName(theme))
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }

                    Section(header: Text("Accent Color")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 12) {
                            ForEach(accentOptions, id: \.self) { color in
                                ColorButton(color: color)
                                    .environmentObject(settingsState)
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    Toggle("Enable Notifications", isOn: $settingsState.notificationsEnabled)
                        .foregroundColor(.primary)

                    Toggle("Auto Expiration Alerts", isOn: $settingsState.autoExpirationAlerts)
                        .foregroundColor(.primary)

                    Section(header: Text("Expiration Alert Timing")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {
                        Stepper(
                            "Alert \(settingsState.expirationAlertDaysBefore) day(s) before expiration",
                            value: $settingsState.expirationAlertDaysBefore,
                            in: 0...14
                        )

                        DatePicker(
                            "Alert Time",
                            selection: $settingsState.expirationAlertTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Section(header: Text("Grocery Budget")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                    ) {

                        VStack(alignment: .leading, spacing: 12) {

                            Text("Manage your grocery spending limits below. You can adjust your weekly, monthly, and yearly budgets anytime.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.bottom, 4)

                            HStack {
                                Text("Weekly Budget")
                                    .foregroundColor(.primary)
                                Spacer()
                                TextField("$", value: $budgetState.weeklyBudget, format: .number)
                                    .keyboardType(.decimalPad)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil
                                                )
                                            }
                                        }
                                    }
                                    .frame(width: 100)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            HStack {
                                Text("Monthly Budget")
                                    .foregroundColor(.primary)
                                Spacer()
                                TextField("$", value: $budgetState.monthlyBudget, format: .number)
                                    .keyboardType(.decimalPad)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil
                                                )
                                            }
                                        }
                                    }
                                    .frame(width: 100)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            HStack {
                                Text("Yearly Budget")
                                    .foregroundColor(.primary)
                                Spacer()
                                TextField("$", value: $budgetState.yearlyBudget, format: .number)
                                    .keyboardType(.decimalPad)
                                    .toolbar {
                                        ToolbarItemGroup(placement: .keyboard) {
                                            Spacer()
                                            Button("Done") {
                                                UIApplication.shared.sendAction(
                                                    #selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil
                                                )
                                            }
                                        }
                                    }
                                    .frame(width: 100)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }

                            Toggle("Enable Overspending Alerts", isOn: $budgetState.alertsEnabled)
                                .foregroundColor(.primary)

                            Toggle("Enable Weekly Summary Notifications", isOn: $budgetState.weeklySummaryEnabled)
                                .foregroundColor(.primary)

                            DatePicker(
                                "Summary Notification Time",
                                selection: $budgetState.alertTime,
                                displayedComponents: .hourAndMinute
                            )
                        }
                    }

                    // RESET BUTTONS
                    Section {
                        Button("Reset All Items & History") {
                            showResetItemsAlert = true
                        }
                        .foregroundColor(.red)
                        .alert("Delete ALL Items and History?", isPresented: $showResetItemsAlert) {
                            Button("Delete", role: .destructive) {

                                // ⭐ CLEAR ITEMS + ITEM HISTORY
                                itemState.clearAllItemsAndHistory()

                                // ⭐ CLEAR RECEIPT HISTORY (your request)
                                receiptHistory.history.removeAll()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This action cannot be undone. All items, item history, and scanned receipt history will be permanently deleted.")
                        }

                        Button("Clear All Alerts") {
                            showResetAlertsAlert = true
                        }
                        .foregroundColor(.red)
                        .alert("Delete ALL Alerts?", isPresented: $showResetAlertsAlert) {
                            Button("Delete", role: .destructive) {
                                alertState.alerts.removeAll()
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("This will permanently delete every alert, including auto‑generated expiration alerts.")
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)

                Spacer()
            }
        }
    }

    func applyAppearance() {
        let theme = settingsState.selectedTheme

        switch theme {
        case .light:
            overrideSystemAppearance(.light)
        case .dark:
            overrideSystemAppearance(.dark)
        case .minimalWhite:
            overrideSystemAppearance(.light)
        case .highContrast:
            overrideSystemAppearance(.light)
        default:
            overrideSystemAppearance(.light)
        }
    }
}

struct ColorButton: View {
    @EnvironmentObject var settingsState: SettingsState
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 32, height: 32)
            .onTapGesture {
                settingsState.accentColor = color
            }
    }
}

func themeDisplayName(_ theme: AppTheme) -> String {
    switch theme {
    case .light: return "Light"
    case .dark: return "Dark"
    case .aurora: return "Aurora Gradient"
    case .sunset: return "Sunset Glow"
    case .ocean: return "Ocean Blue"
    case .forest: return "Forest Green"
    case .minimalWhite: return "Minimal White"
    case .highContrast: return "High Contrast"
    case .warm: return "Warm Mode"
    case .cool: return "Cool Mode"
    }
}

func overrideSystemAppearance(_ style: UIUserInterfaceStyle) {
    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
        for window in windowScene.windows {
            window.overrideUserInterfaceStyle = style
        }
    }
}
