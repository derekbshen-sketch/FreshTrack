//
//  ScanReceiptView.swift
//  FreshTrack
//

import SwiftUI
import PhotosUI
import Vision

struct ScanReceiptView: View {
    @EnvironmentObject var itemState: ItemState
    @EnvironmentObject var settingsState: SettingsState
    @EnvironmentObject var receiptHistory: ReceiptHistoryState
    @EnvironmentObject var alertState: AlertState
    @EnvironmentObject var statisticsState: StatisticsState
    @EnvironmentObject var budgetState: BudgetState
    @Environment(\.dismiss) var dismiss

    @State private var showCamera = false
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?

    @State private var parsedItems: [ScannedItem] = []
    @State private var scanStatus: ScanStatus = .idle
    @State private var ocrText: [String] = []

    @State private var extractedTotalText: String = ""

    enum ScanStatus { case idle, scanning, success, failure }

    let categories = ["Pantry", "Fridge", "Freezer"]

    var body: some View {

        ZStack {
            appBackground(for: settingsState.selectedTheme)
                .ignoresSafeArea()

            ScrollView {
                LazyVStack(spacing: 24) {

                    Text("Scan Receipt")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(
                            themedAccent(
                                for: settingsState.selectedTheme,
                                accent: settingsState.accentColor
                            )
                        )
                        .padding(.top, 20)

                    HStack(spacing: 20) {
                        Button { showCamera = true } label: {
                            ScanButton(title: "Take Photo", icon: "camera.fill", color: .blue)
                        }

                        PhotosPicker(
                            selection: $photoPickerItem,
                            matching: .images,
                            photoLibrary: .shared()
                        ) {
                            ScanButton(title: "Photo Library", icon: "photo.fill.on.rectangle.fill", color: .green)
                        }
                        .onChange(of: photoPickerItem) { _, newValue in
                            loadPhotoPickerImage(newValue)
                        }
                    }

                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    if !ocrText.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Detected Text:")
                                .font(.headline)
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                            VStack(alignment: .leading, spacing: 6) {
                                ForEach(ocrText, id: \.self) { line in
                                    Text(line)
                                        .padding(6)
                                        .background(Color.yellow.opacity(0.3))
                                        .cornerRadius(6)
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Receipt Total")
                                    .font(.headline)
                                    .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                                TextField("Total (e.g. 45.99)", text: $extractedTotalText)
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

                                Button("Extract Total from Receipt") {
                                    if let total = extractTotalFromOCR() {
                                        extractedTotalText = String(format: "%.2f", total)
                                    }
                                }
                                .foregroundColor(
                                    themedAccent(
                                        for: settingsState.selectedTheme,
                                        accent: settingsState.accentColor
                                    )
                                )
                            }
                        }
                        .padding(.horizontal)
                    }

                    switch scanStatus {
                    case .idle:
                        EmptyView()

                    case .scanning:
                        ProgressView("Scanning receipt...")
                            .padding()

                    case .success:
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Items Found:")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(themedTextColor(for: settingsState.selectedTheme))

                            ForEach($parsedItems) { $item in
                                itemCard(item: $item)
                            }

                            VStack(spacing: 20) {
                                Button("Add Custom Item") {
                                    parsedItems.append(
                                        ScannedItem(
                                            name: "New Item",
                                            quantity: 1,
                                            unit: .items,
                                            category: "Pantry",
                                            expirationDate: Date().addingTimeInterval(60*60*24*7),
                                            confidence: 1.0
                                        )
                                    )
                                }

                                Button("Submit Items") {
                                    submitParsedItems()
                                    dismiss()
                                }
                            }
                            .padding(.top, 30)
                        }
                        .padding(.horizontal)

                    case .failure:
                        Text("Could not read the receipt. Please try again.")
                            .foregroundColor(.red)
                            .padding()
                    }

                    Spacer().frame(height: 40)
                }
            }
        }
        .sheet(isPresented: $showCamera) {
            CameraView(image: $selectedImage, onCapture: processImage)
        }
        .navigationTitle("Scan Receipt")
        .navigationBarTitleDisplayMode(.inline)
    }

    func itemCard(item: Binding<ScannedItem>) -> some View {
        VStack(alignment: .leading, spacing: 16) {

            HStack {
                TextField("Item name", text: item.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Spacer()

                Button {
                    removeItem(id: item.wrappedValue.id)
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .font(.title3)
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Quantity")
                TextField("Qty", value: item.quantity, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Unit")
                Picker("Unit", selection: item.unit) {
                    ForEach(QuantityUnit.allCases, id: \.self) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                Picker("Category", selection: item.category) {
                    ForEach(categories, id: \.self) { cat in
                        Text(cat).tag(cat)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Expiration Date")
                NavigationLink {
                    ExpirationPickerView(initialDate: item.wrappedValue.expirationDate) { newDate in
                        item.expirationDate.wrappedValue = newDate
                    }
                } label: {
                    HStack {
                        Text(formatted(item.wrappedValue.expirationDate))
                        Spacer()
                        Image(systemName: "calendar")
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.4))
        .cornerRadius(12)
    }

    func submitParsedItems() {
        let snapshot = parsedItems

        receiptHistory.addReceipt(items: snapshot, image: selectedImage)

        for scanned in snapshot {
            let newItem = Item(
                name: scanned.name,
                category: scanned.category,
                expirationDate: scanned.expirationDate,
                quantity: scanned.quantity,
                quantityType: scanned.unit.rawValue
            )

            itemState.addItem(newItem, settingsState: settingsState, alertState: alertState)
        }

        if let total = Double(extractedTotalText) {
            statisticsState.addSpending(
                itemName: "Grocery Trip",
                amount: total,
                date: Date()
            )
            budgetState.evaluateOverspending(with: statisticsState)
        }

        parsedItems = []
        scanStatus = .idle
        selectedImage = nil
        ocrText = []
        extractedTotalText = ""
    }

    func extractTotalFromOCR() -> Double? {
        let candidates = ocrText.filter {
            $0.lowercased().contains("total") || $0.contains("$")
        }

        guard let line = candidates.last ?? ocrText.last else { return nil }

        let cleaned = line.replacingOccurrences(of: ",", with: "")
        let pattern = #"([-+]?[0-9]*\.?[0-9]+)"#
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(cleaned.startIndex..<cleaned.endIndex, in: cleaned)

        if let match = regex?.firstMatch(in: cleaned, options: [], range: range),
           let r = Range(match.range(at: 1), in: cleaned) {
            return Double(String(cleaned[r]))
        }

        return nil
    }

    func formatted(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func removeItem(id: UUID) {
        if let index = parsedItems.firstIndex(where: { $0.id == id }) {
            parsedItems.remove(at: index)
        }
    }

    func processImage(_ image: UIImage) {
        selectedImage = image
        scanStatus = .scanning

        ReceiptAIEngine.shared.process(image: image) { items, ocrLines in
            DispatchQueue.main.async {
                self.ocrText = ocrLines
                if items.isEmpty {
                    self.scanStatus = .failure
                } else {
                    self.parsedItems = items
                    self.scanStatus = .success
                }
            }
        }
    }

    func loadPhotoPickerImage(_ item: PhotosPickerItem?) {
        guard let item else { return }

        scanStatus = .scanning

        item.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let data, let uiImage = UIImage(data: data) {
                        processImage(uiImage)
                    } else {
                        scanStatus = .failure
                    }
                case .failure:
                    scanStatus = .failure
                }
            }
        }
    }
}
