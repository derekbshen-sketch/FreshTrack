//
//  StatisticsView.swift
//  FreshTrack
//
//  Created by Derek Shen on 8/3/26.
//

import SwiftUI
import Charts
import UserNotifications

struct StatisticsView: View {
    @EnvironmentObject var statisticsState: StatisticsState
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var budgetState: BudgetState

    @State private var manualTotal: String = ""
    @State private var manualItemName: String = ""
    @State private var manualDate: Date = Date()

    @State private var graphRange: StatisticsRange = .weekly
    @State private var showConfirmation: Bool = false

    // Editing modal
    @State private var editingEntry: SpendingEntry?
    @State private var editAmount: String = ""
    @State private var editName: String = ""
    @State private var editDate: Date = Date()

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    Text("Statistics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(
                            themedAccent(
                                for: settingsState.selectedTheme,
                                accent: settingsState.accentColor
                            )
                        )
                        .padding(.top, 20)

                    manualInputSection
                    summaryTotalsSection
                    spendingGraphSection
                    pieChartSection
                    budgetOverviewSection
                    editEntriesSection   // ⭐ NEW SECTION

                    if showConfirmation {
                        Text("Weekly summary scheduled!")
                            .foregroundColor(
                                themedTextColor(for: settingsState.selectedTheme)
                            )
                            .font(.headline)
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Statistics")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingEntry) { entry in
            editEntrySheet(entry)
        }
        .onAppear {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }
}

extension StatisticsView {

    // MARK: - Manual Input Section
    var manualInputSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Add Manual Spending")
                    .font(.headline)
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                TextField("Total amount (e.g. 45.99)", text: $manualTotal)
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
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextField("Item name (optional)", text: $manualItemName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                DatePicker("Date", selection: $manualDate, displayedComponents: .date)

                Button("Add Spending") {
                    if let amount = Double(manualTotal) {
                        let name = manualItemName.trimmingCharacters(in: .whitespacesAndNewlines)
                        statisticsState.addSpending(
                            itemName: name.isEmpty ? nil : name,
                            amount: amount,
                            date: manualDate
                        )
                        manualTotal = ""
                        manualItemName = ""
                    }
                }
                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - Summary Totals Section
    var summaryTotalsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Summary")
                    .font(.headline)
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                Text("Weekly total: $\(statisticsState.weeklySpending(), specifier: "%.2f")")
                Text("Monthly total: $\(statisticsState.monthlySpending(), specifier: "%.2f")")
                Text("Yearly total: $\(statisticsState.yearlySpending(), specifier: "%.2f")")
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - Spending Graph Section
    var spendingGraphSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Graph")
                    .font(.headline)
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                Picker("Range", selection: $graphRange) {
                    ForEach(StatisticsRange.allCases, id: \.self) { r in
                        Text(r.rawValue).tag(r)
                    }
                }
                .pickerStyle(.segmented)

                let data = selectedData()
                let budget = selectedBudget()

                if data.count < minimumRequired() {
                    Text("Not enough data to generate graph.")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))
                        .padding(.top, 8)
                } else {
                    Chart {
                        ForEach(data, id: \.date) { point in
                            LineMark(
                                x: .value("Date", point.date),
                                y: .value("Spent", point.amount)
                            )
                            .foregroundStyle(point.amount > budget ? .red : .green)
                            .interpolationMethod(.catmullRom)

                            PointMark(
                                x: .value("Date", point.date),
                                y: .value("Spent", point.amount)
                            )
                            .foregroundStyle(.blue)
                        }

                        RuleMark(y: .value("Budget", budget))
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 2, dash: [5]))
                    }
                    .frame(height: 250)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - Pie Chart Section
    var pieChartSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Spending Distribution")
                    .font(.headline)
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                let items = statisticsState.topItems(limit: 10)

                if items.isEmpty {
                    Text("No spending data yet.")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))
                } else {
                    Chart(items.indices, id: \.self) { index in
                        let item = items[index]
                        SectorMark(
                            angle: .value("Amount", item.total),
                            innerRadius: .ratio(0.5)
                        )
                        .foregroundStyle(by: .value("Item", item.name))
                    }
                    .frame(height: 250)
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - Budget Overview Section
    var budgetOverviewSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {

                Text("Budget Overview")
                    .font(.headline)
                    .foregroundColor(
                        themedTextColor(for: settingsState.selectedTheme)
                    )

                let weeklyDiff = statisticsState.weeklyDifference(from: budgetState.weeklyBudget)
                let monthlyDiff = statisticsState.monthlyDifference(from: budgetState.monthlyBudget)
                let yearlyDiff = statisticsState.yearlyDifference(from: budgetState.yearlyBudget)

                BudgetRow(
                    label: "Weekly",
                    spending: statisticsState.weeklySpending(),
                    budget: budgetState.weeklyBudget,
                    diff: weeklyDiff
                )

                BudgetRow(
                    label: "Monthly",
                    spending: statisticsState.monthlySpending(),
                    budget: budgetState.monthlyBudget,
                    diff: monthlyDiff
                )

                BudgetRow(
                    label: "Yearly",
                    spending: statisticsState.yearlySpending(),
                    budget: budgetState.yearlyBudget,
                    diff: yearlyDiff
                )

                Button("Schedule Weekly Summary Notification") {
                    budgetState.scheduleWeeklySummary(with: statisticsState)
                    showConfirmation = true
                }
                .buttonStyle(.borderedProminent)
                .tint(.gray)
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - NEW: Edit Entries Section
    var editEntriesSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                Text("Edit Spending Entries")
                    .font(.headline)
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                if statisticsState.entries.isEmpty {
                    Text("No spending entries yet.")
                        .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.7))
                } else {
                    ForEach(statisticsState.entries.indices, id: \.self) { index in
                        let entry = statisticsState.entries[index]

                        HStack {
                            VStack(alignment: .leading) {
                                Text(entry.itemName ?? "Grocery Trip")
                                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))
                                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            Text("$\(entry.amount, specifier: "%.2f")")
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                            Button("Edit") {
                                editingEntry = entry
                                editAmount = String(entry.amount)
                                editName = entry.itemName ?? ""
                                editDate = entry.date
                            }
                            .padding(.leading, 8)

                            Button("Delete") {
                                statisticsState.entries.remove(at: index)
                            }
                            .foregroundColor(.red)
                            .padding(.leading, 8)
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6).opacity(0.4))
            .cornerRadius(12)
        }
    }

    // MARK: - Edit Sheet
    func editEntrySheet(_ entry: SpendingEntry) -> some View {
        NavigationView {
            Form {
                Section("Edit Entry") {
                    TextField("Amount", text: $editAmount)
                        .keyboardType(.decimalPad)

                    TextField("Item Name", text: $editName)

                    DatePicker("Date", selection: $editDate, displayedComponents: .date)
                }

                Button("Save Changes") {
                    if let index = statisticsState.entries.firstIndex(where: { $0.id == entry.id }) {
                        if let newAmount = Double(editAmount) {
                            statisticsState.entries[index].amount = newAmount
                            statisticsState.entries[index].itemName = editName.isEmpty ? nil : editName
                            statisticsState.entries[index].date = editDate
                        }
                    }
                    editingEntry = nil
                }
                .foregroundColor(.blue)

                Button("Delete Entry") {
                    if let index = statisticsState.entries.firstIndex(where: { $0.id == entry.id }) {
                        statisticsState.entries.remove(at: index)
                    }
                    editingEntry = nil
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Edit Spending")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Graph Helpers
    func selectedData() -> [(date: Date, amount: Double)] {
        switch graphRange {
        case .weekly: return statisticsState.weeklyData()
        case .monthly: return statisticsState.monthlyData()
        case .yearly: return statisticsState.yearlyData()
        }
    }

    func selectedBudget() -> Double {
        switch graphRange {
        case .weekly: return budgetState.weeklyBudget
        case .monthly: return budgetState.monthlyBudget
        case .yearly: return budgetState.yearlyBudget
        }
    }

    func minimumRequired() -> Int {
        switch graphRange {
        case .weekly: return 3
        case .monthly: return 7
        case .yearly: return 3
        }
    }
}

struct BudgetRow: View {
    @EnvironmentObject var settingsState: SettingsState

    let label: String
    let spending: Double
    let budget: Double
    let diff: Double

    var body: some View {
        HStack {
            Text("\(label) Spending")
                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text("Spent: $\(spending, specifier: "%.2f")")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                Text("Budget: $\(budget, specifier: "%.2f")")
                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme).opacity(0.85))

                Text(diffText)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(diffColor.opacity(0.25))
                    .cornerRadius(6)
                    .font(.caption)
            }
        }
        .padding(.vertical, 4)
    }

    private var diffText: String {
        if diff > 0 { return "Over by $\(String(format: "%.2f", diff))" }
        if diff < 0 { return "Under by $\(String(format: "%.2f", -diff))" }
        return "Exactly on budget"
    }

    private var diffColor: Color {
        if diff > 0 { return .red }
        if diff < 0 { return .green }
        return .gray
    }
}
