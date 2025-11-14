//
//  ThresholdViewBlue.swift
//  BekahSeizureSense
//
//  Created by Bekah Muldoon on 11/12/25.
//
import SwiftUI

struct ThresholdViewBlue: View {

    enum HRMode: String, CaseIterable, Identifiable {
        case adaptive = "Adaptive Thresholding"
        case nonAdaptive = "Non-Adaptive Thresholding"
        var id: String { rawValue }
    }

    @State private var selectedHRMode: HRMode = .adaptive
    @State private var hrMinValue: Int = 60
    @State private var hrMaxValue: Int = 180
    @State private var sensitivityLevel = 5

    private var intFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }

    var body: some View {
        NavigationView {
            ZStack {
                // BACKGROUND
                Color(red: 0.85, green: 0.93, blue: 1.0)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {

                        Spacer().frame(height: 40)

                        // ----------------------------
                        // HR BOX
                        // ----------------------------
                        VStack(alignment: .leading, spacing: 15) {
                            Text("HR Thresholding")
                                .font(.headline)

                            Picker("Mode", selection: $selectedHRMode) {
                                ForEach(HRMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            if selectedHRMode == .nonAdaptive {
                                HStack {
                                    Text("Min:")
                                    TextField("Min", value: $hrMinValue, formatter: intFormatter)
                                        .textFieldStyle(.roundedBorder)
                                }

                                HStack {
                                    Text("Max:")
                                    TextField("Max", value: $hrMaxValue, formatter: intFormatter)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)

                        // ----------------------------
                        // MOVEMENT BOX
                        // ----------------------------
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Movement Thresholding")
                                .font(.headline)

                            HStack {
                                Text("Sensitivity Level")

                                Spacer()

                                Picker("", selection: $sensitivityLevel) {
                                    ForEach(1..<11) { level in
                                        Text("\(level)").tag(level)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 80)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(radius: 2)

                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Threshold Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ThresholdViewBlue()
}
