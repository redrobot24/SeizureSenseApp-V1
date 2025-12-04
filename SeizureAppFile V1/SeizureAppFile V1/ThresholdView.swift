//
//  ThresholdView.swift
//  SeizureAppFile V1
//
//  Created by Bekah Muldoon on 11/13/25.
//

import SwiftUI

struct ThresholdSettingsView: View {
    //  - HR Thresholding
    enum HRMode: String, CaseIterable, Identifiable {
        case adaptive = "Adaptive"
        case nonAdaptive = "Non-Adaptive"
        var id: String { rawValue }
    }

    @State private var selectedHRMode: HRMode = .adaptive
    @State private var hrMinValue: Int = 60
    @State private var hrMaxValue: Int = 180

    //  - Movement Thresholding
    @State private var sensitivityLevel = 5

    private var intFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }

    init() {
        UITableView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ZStack {

            NavigationView {
                Form {
                    //  HR Thresholding
                    Section(header: Text("HR Thresholding")) {
                        Picker("Mode", selection: $selectedHRMode) {
                            ForEach(HRMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)

                        if selectedHRMode == .nonAdaptive {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Min:")
                                    TextField("Min HR", value: $hrMinValue, formatter: intFormatter)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                                HStack {
                                    Text("Max:")
                                    TextField("Max HR", value: $hrMaxValue, formatter: intFormatter)
                                        .keyboardType(.numberPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }

                    // - Movement Thresholding
                    Section(header: Text("Movement Thresholding")) {
                        Picker("Sensitivity Level", selection: $sensitivityLevel) {
                            ForEach(1..<11) { level in
                                Text("\(level)").tag(level)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .navigationTitle("Threshold Settings")
            }
        }
    }
}

#Preview {
    ThresholdSettingsView()
}
