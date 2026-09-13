//
//  ContentView.swift
//  FreshTrack
//
//  Created by Derek Shen on 7/27/26.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var groceryListState: GroceryListState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var receiptHistory: ReceiptHistoryState
    @EnvironmentObject var statisticsState: StatisticsState

    @State private var isLoading = true   // ⭐ NEW

    // QUICK STATS
    var expiredCount: Int {
        itemState.items.filter { $0.isExpired }.count
    }

    var expiringSoonCount: Int {
        itemState.items.filter { !$0.isExpired && $0.daysUntilExpiration <= 3 }.count
    }

    var totalCount: Int {
        itemState.items.count
    }

    var recentItems: [Item] {
        Array(
            itemState.items
                .sorted(by: { $0.dateAdded > $1.dateAdded })
                .prefix(5)
        )
    }

    var body: some View {

        // ⭐ FULL SCREEN GRADIENT BACKGROUND + LOADING OVERLAY
        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {

                    // HEADER
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Welcome Back")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(
                                themedAccent(
                                    for: settingsState.selectedTheme,
                                    accent: settingsState.accentColor
                                )
                            )

                        Text("Here’s what’s happening today")
                            .foregroundColor(
                                themedTextColor(for: settingsState.selectedTheme)
                                    .opacity(0.7)
                            )
                    }
                    .padding(.horizontal)

                    // CARTOON FRIDGE + FREEZER + PANTRY
                    VStack(spacing: 24) {
                        FridgeView()
                        FreezerView()
                        PantryView()
                        FreshnessKey()
                    }

                    // QUICK STATS
                    HStack(spacing: 12) {
                        StatCard(title: "Expired", value: expiredCount, color: .red)
                        StatCard(title: "Expiring Soon", value: expiringSoonCount, color: .green)
                        StatCard(title: "Total Items", value: totalCount, color: .blue)
                    }
                    .padding(.horizontal)

                    // QUICK ACTIONS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Quick Actions")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                themedTextColor(for: settingsState.selectedTheme)
                            )

                        HStack {
                            DashboardButton(
                                title: "Grocery List",
                                icon: "cart.fill",
                                color: .green,
                                destination: AnyView(GroceryListView())
                            )

                            DashboardButton(
                                title: "Scan Receipt",
                                icon: "camera.fill",
                                color: .purple,
                                destination: AnyView(ScanReceiptView())
                            )
                        }

                        HStack {
                            DashboardButton(
                                title: "Add Currently Stored Item",
                                icon: "plus.circle.fill",
                                color: .blue,
                                destination: AnyView(AddItemView())
                            )

                            DashboardButton(
                                title: "Settings",
                                icon: "gearshape.fill",
                                color: .orange,
                                destination: AnyView(SettingsView())
                            )
                        }

                        HStack {
                            DashboardButton(
                                title: "Timeline",
                                icon: "clock.fill",
                                color: .pink,
                                destination: AnyView(TimelineView())
                            )

                            DashboardButton(
                                title: "Alerts",
                                icon: "bell.fill",
                                color: .red,
                                destination: AnyView(AlertsView())
                            )
                        }

                        HStack {
                            DashboardButton(
                                title: "History",
                                icon: "clock.arrow.circlepath",
                                color: .teal,
                                destination: AnyView(HistoryView())
                            )

                            Spacer()
                        }

                        HStack {
                            DashboardButton(
                                title: "Finance",
                                icon: "chart.bar.fill",
                                color: .indigo,
                                destination: AnyView(StatisticsView())
                            )

                            Spacer()
                        }
                    }
                    .padding(.horizontal)

                    // RECOMMENDED FOODS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Foods")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                themedTextColor(for: settingsState.selectedTheme)
                            )

                        let seasonalFoods: [String: [String]] = [
                            "winter": ["Butternut Squash", "Sweet Potatoes", "Citrus Fruits", "Pomegranates", "Brussels Sprouts"],
                            "spring": ["Asparagus", "Strawberries", "Peas", "Radishes", "Artichokes"],
                            "summer": ["Watermelon", "Blueberries", "Tomatoes", "Corn", "Peaches"],
                            "fall": ["Pumpkin", "Apples", "Pears", "Cranberries", "Cauliflower"]
                        ]

                        let similarFoods: [String: [String]] = [
                            "milk": ["Yogurt", "Cream Cheese", "Oat Milk", "Cottage Cheese"],
                            "bread": ["Bagels", "Tortillas", "Pita", "Croissants"],
                            "apple": ["Pears", "Peaches", "Plums", "Grapes"],
                            "chicken": ["Turkey", "Salmon", "Tofu", "Pork Tenderloin"],
                            "rice": ["Quinoa", "Couscous", "Barley", "Farro"],
                            "eggs": ["Greek Yogurt", "Protein Pancakes", "Cottage Cheese"],
                            "lettuce": ["Spinach", "Arugula", "Kale", "Mixed Greens"],
                            "pasta": ["Gnocchi", "Ravioli", "Rice Noodles", "Udon"],
                            "banana": ["Plantains", "Mango", "Papaya", "Pineapple"],
                            "tomato": ["Red Peppers", "Eggplant", "Zucchini", "Cucumber"],
                            "potato": ["Sweet Potato", "Turnips", "Parsnips", "Carrots"],
                            "cheese": ["Feta", "Mozzarella", "Goat Cheese", "Ricotta"],
                            "fish": ["Salmon", "Tuna", "Cod", "Halibut"],
                            "berries": ["Strawberries", "Blackberries", "Raspberries"],
                            "beef": ["Pork", "Lamb", "Turkey"],
                            "yogurt": ["Kefir", "Skyr", "Cottage Cheese"],
                            "carrot": ["Onion", "Beet", "Turnip"],
                            "orange": ["Mandarin", "Grapefruit", "Lemon"],
                            "onion": ["Garlic", "Leeks", "Green Onions"],
                            "spinach": ["Kale", "Swiss Chard", "Arugula"],
                            "garlic": ["Onion", "Green Onion", "Soy Sauce"]
                        ]

                        let season = currentSeason()
                        let seasonal = seasonalFoods[season]?.shuffled().prefix(3) ?? []

                        let userFoods = itemState.items.map { $0.name.lowercased() }

                        let similar = userFoods.compactMap { similarFoods[$0] }
                                               .flatMap { $0 }
                                               .shuffled()
                                               .prefix(3)

                        let combined = Array(seasonal) + Array(similar)

                        if combined.isEmpty {
                            Text("Add more items to get recommendations!")
                                .foregroundColor(
                                    themedTextColor(for: settingsState.selectedTheme)
                                        .opacity(0.7)
                                )
                        } else {
                            ForEach(combined, id: \.self) { food in
                                HStack {
                                    Text(food)
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Spacer()

                                    Text(seasonal.contains(food) ? "Seasonal Pick" : "You Might Like")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding()
                                .background(randomColor())
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // RECENT ITEMS
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recently Added")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(
                                themedTextColor(for: settingsState.selectedTheme)
                            )

                        if recentItems.isEmpty {
                            Text("No recent items yet.")
                                .foregroundColor(
                                    themedTextColor(for: settingsState.selectedTheme)
                                        .opacity(0.7)
                                )
                        } else {
                            ForEach(recentItems) { item in
                                VStack(alignment: .leading) {
                                    Text(item.name)
                                        .font(.headline)
                                        .foregroundColor(
                                            themedTextColor(for: settingsState.selectedTheme)
                                        )

                                    Text("Expires: \(item.formattedExpiration)")
                                        .font(.caption)
                                        .foregroundColor(
                                            themedTextColor(for: settingsState.selectedTheme)
                                                .opacity(0.7)
                                        )
                                }
                                .padding()
                                .background(Color(.systemGray6).opacity(0.4))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)

            // ⭐ LOADING OVERLAY
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            }
        }
        .navigationTitle("Dashboard")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // simulate loading; replace with real logic if needed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isLoading = false
            }
        }
    }
}



// SUPPORTING VIEWS

struct StatCard: View {
    @EnvironmentObject var settingsState: SettingsState
    
    let title: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text("\(value)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            themedAccent(
                for: settingsState.selectedTheme,
                accent: settingsState.accentColor
            )
        )
        .cornerRadius(16)
    }
}

struct DashboardButton: View {
    @EnvironmentObject var settingsState: SettingsState
    let title: String
    let icon: String
    let color: Color
    let destination: AnyView

    var body: some View {
        NavigationLink(destination: destination) {
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
            .background(
                LinearGradient(
                    colors: [
                        themedAccent(for: settingsState.selectedTheme, accent: settingsState.accentColor),
                        themedAccent(for: settingsState.selectedTheme, accent: settingsState.accentColor).opacity(0.7)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
        }
    }
}

// HELPERS

func randomColor() -> Color {
    let colors: [Color] = [.blue, .green, .purple, .pink, .orange, .teal, .indigo]
    return colors.randomElement() ?? .blue
}

func currentSeason() -> String {
    let month = Calendar.current.component(.month, from: Date())
    switch month {
    case 12, 1, 2: return "winter"
    case 3, 4, 5: return "spring"
    case 6, 7, 8: return "summer"
    default: return "fall"
    }
}

func freshnessColor(for item: Item) -> Color {
    if item.isExpired { return .red }

    switch item.daysUntilExpiration {
    case 0...2: return .orange
    case 3...5: return .yellow
    default: return .green
    }
}

func formatted(_ date: Date) -> String {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .short
    return f.string(from: date)
}

func generatePositions(count: Int, in size: CGSize) -> [CGPoint] {
    var positions: [CGPoint] = []
    let maxAttempts = 200

    for _ in 0..<count {
        var attempts = 0
        var newPoint: CGPoint

        repeat {
            attempts += 1
            newPoint = CGPoint(
                x: CGFloat.random(in: 40...(size.width - 40)),
                y: CGFloat.random(in: 40...(size.height - 40))
            )
        } while positions.contains(where: { existing in
            hypot(existing.x - newPoint.x, existing.y - newPoint.y) < 55
        }) && attempts < maxAttempts

        positions.append(newPoint)
    }

    return positions
}
