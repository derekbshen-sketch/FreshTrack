//
//  StatisticsGraphView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI
import Charts

struct StatisticsGraphView: View {
    @EnvironmentObject var statisticsState: StatisticsState
    @EnvironmentObject var budgetState: BudgetState
    @EnvironmentObject var settingsState: SettingsState

    @State private var range: StatisticsRange = .weekly

    var body: some View {
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 20) {

                Text("Spending Graph")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(
                        themedAccent(
                            for: settingsState.selectedTheme,
                            accent: settingsState.accentColor
                        )
                    )
                    .padding(.top, 20)

                Picker("Range", selection: $range) {
                    ForEach(StatisticsRange.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                let data = selectedData()
                let budget = selectedBudget()

                if data.count < minimumRequired() {
                    Text("Not enough data to generate graph.")
                        .foregroundColor(
                            themedTextColor(for: settingsState.selectedTheme).opacity(0.7)
                        )
                        .padding()
                } else {
                    Chart {
                        // Spending line
                        ForEach(data, id: \.date) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Spent", point.amount)
                            )
                            .foregroundStyle(.blue)
                            .interpolationMethod(.catmullRom)
                        }

                        // Budget line
                        RuleMark(y: .value("Budget", budget))
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                    .frame(height: 250)
                    .padding()
                }

                Spacer()
            }
        }
        .navigationTitle("Spending Graph")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers

    func selectedData() -> [(date: Date, amount: Double)] {
        switch range {
        case .weekly: return statisticsState.weeklyData()
        case .monthly: return statisticsState.monthlyData()
        case .yearly: return statisticsState.yearlyData()
        }
    }

    func selectedBudget() -> Double {
        switch range {
        case .weekly: return budgetState.weeklyBudget
        case .monthly: return budgetState.monthlyBudget
        case .yearly: return budgetState.yearlyBudget
        }
    }

    func minimumRequired() -> Int {
        switch range {
        case .weekly: return 3
        case .monthly: return 7
        case .yearly: return 3
        }
    }
}
