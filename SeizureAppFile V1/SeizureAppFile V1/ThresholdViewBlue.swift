//
//  ThresholdViewBlue.swift
//  SeizureAppFile V1
//
//  Created by Bekah Muldoon on 11/13/25.
//
import SwiftUI

struct ThresholdViewBlue: View {
    
    enum HRMode: String, CaseIterable, Identifiable {
        case adaptive = "Adaptive"
        case nonAdaptive = "Non-Adaptive"
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
        ZStack {
            // blue background
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {

                    // Add top spacing to move boxes down
                    Spacer()
                        .frame(height: 40)

                    // --- HR Thresholding Box ---
                    VStack(alignment: .leading, spacing: 15) {
                        Text("HR Thresholding")
                            .font(.headline)

                        Picker("Mode", selection: $selectedHRMode) {
                            ForEach(HRMode.allCases) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                        .pickerStyle(.segmented)

                        if selectedHRMode == .nonAdaptive {
                            HStack {
                                Text("Min:")
                                TextField("Min HR", value: $hrMinValue, formatter: intFormatter)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            }

                            HStack {
                                Text("Max:")
                                TextField("Max HR", value: $hrMaxValue, formatter: intFormatter)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)     //makes it full screen width
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    // --- Movement Thresholding Box ---
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
                            .pickerStyle(.menu)   // dropdown menu
                            .frame(width: 80)      
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)


                }
                .padding(.horizontal)  // consistent left/right padding for both boxes
            }

        }
    }
}

#Preview {
    ThresholdViewBlue()
}

