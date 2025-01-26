import SwiftUI

struct ContentView: View {
    @State private var selectedExplosives: [String: Bool] = [
        "Deta Sheet": false,
        "Det Cord": false,
        "Composition C-4": false,
        "Mk 140 Booster": false,
        "E.C.T.": false
    ]
    @State private var initiatingSystem: String = ""
    @State private var detaSheetDimensions: (Double, Double) = (0.0, 0.0) // Length x Width in inches
    @State private var detaSheetC: Double = 0.0
    @State private var detCordLength: Double = 0.0 // Length in feet
    @State private var detCordGrainsPerFoot: Double = 0.0
    @State private var c4Pounds: Double = 0.0
    @State private var boosterSelection: String = ""
    @State private var ectLength: Double = 0.0
    @State private var ectGrainsPerFoot: Double = 0.0

    @State private var outputNEW: Double = 0.0
    @State private var outputExternalMSD: Int = 0
    @State private var outputInternalMSD: Int = 0

    let reFactors: [String: Double] = [
        "Det Cord": 1.66,
        "E.C.T.": 1.27,
        "Deta Sheet": 1.19,
        "Mk 140 Booster": 1.19,
        "Composition C-4": 1.34
    ]

    let initiatingSystemNEW: [String: Double] = [
        "30' lead": 0.003,
        "3.8 second delay": 0.004,
        "Dual Caps": 0.007
    ]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Explosives")) {
                    ForEach(selectedExplosives.keys.sorted(), id: \.self) { explosive in
                        Toggle(isOn: $selectedExplosives[explosive]!) {
                            Text(explosive)
                        }
                    }
                }

                Section(header: Text("Initiating System")) {
                    Picker("Select Initiating System", selection: $initiatingSystem) {
                        ForEach(initiatingSystemNEW.keys.sorted(), id: \.self) { system in
                            Text(system)
                        }
                    }
                }

                if selectedExplosives["Deta Sheet"] == true {
                    Section(header: Text("Deta Sheet")) {
                        TextField("Length (in inches)", value: $detaSheetDimensions.0, format: .number)
                        TextField("Width (in inches)", value: $detaSheetDimensions.1, format: .number)
                        TextField("C# Value", value: $detaSheetC, format: .number)
                    }
                }

                if selectedExplosives["Det Cord"] == true {
                    Section(header: Text("Det Cord")) {
                        TextField("Length (in feet)", value: $detCordLength, format: .number)
                        TextField("Grains per foot", value: $detCordGrainsPerFoot, format: .number)
                    }
                }

                if selectedExplosives["Composition C-4"] == true {
                    Section(header: Text("Composition C-4")) {
                        TextField("Pounds Used", value: $c4Pounds, format: .number)
                    }
                }

                if selectedExplosives["Mk 140 Booster"] == true {
                    Section(header: Text("Mk 140 Booster")) {
                        Picker("Select Booster", selection: $boosterSelection) {
                            Text("Full Booster").tag("Full Booster")
                            Text("1/2 Booster").tag("1/2 Booster")
                            Text("1/3 Booster").tag("1/3 Booster")
                        }
                    }
                }

                if selectedExplosives["E.C.T."] == true {
                    Section(header: Text("E.C.T.")) {
                        TextField("Length (in feet)", value: $ectLength, format: .number)
                        TextField("Grains per foot", value: $ectGrainsPerFoot, format: .number)
                    }
                }

                Button("Calculate") {
                    calculateResults()
                }

                if outputNEW > 0 {
                    Section(header: Text("Results")) {
                        Text("N.E.W.: \(outputNEW, specifier: "%.2f") lbs TNT")
                        Text("External MSD: \(outputExternalMSD) feet")
                        Text("Internal MSD: \(outputInternalMSD) feet")
                    }
                }
            }
            .navigationTitle("Explosives Calculator")
        }
    }

    func calculateResults() {
        var totalNEW: Double = 0.0

        if selectedExplosives["Deta Sheet"] == true {
            let area = detaSheetDimensions.0 * detaSheetDimensions.1
            let grams = area * detaSheetC
            let pounds = grams / 453.6
            totalNEW += pounds * reFactors["Deta Sheet"]!
        }

        if selectedExplosives["Det Cord"] == true {
            let grains = detCordLength * detCordGrainsPerFoot
            let pounds = grains / 7000
            totalNEW += pounds * reFactors["Det Cord"]!
        }

        if selectedExplosives["Composition C-4"] == true {
            totalNEW += c4Pounds * reFactors["Composition C-4"]!
        }

        if selectedExplosives["Mk 140 Booster"] == true {
            let boosterPounds: Double
            switch boosterSelection {
            case "Full Booster":
                boosterPounds = 20 / 453.6
            case "1/2 Booster":
                boosterPounds = (20 / 2) / 453.6
            case "1/3 Booster":
                boosterPounds = (20 / 3) / 453.6
            default:
                boosterPounds = 0.0
            }
            totalNEW += boosterPounds * reFactors["Mk 140 Booster"]!
        }

        if selectedExplosives["E.C.T."] == true {
            let grains = ectLength * ectGrainsPerFoot
            let pounds = grains / 7000
            totalNEW += pounds * reFactors["E.C.T."]!
        }

        if let initiatingSystemValue = initiatingSystemNEW[initiatingSystem] {
            totalNEW += initiatingSystemValue
        }

        outputNEW = totalNEW
        outputExternalMSD = Int(ceil(pow(totalNEW, 1.0/3.0) * 18))
        outputInternalMSD = Int(ceil(pow(totalNEW, 1.0/3.0) * 36))
    }
}

@main
struct ExplosivesCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
