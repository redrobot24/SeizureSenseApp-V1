//
//  ThresholdViewBlue.swift
//  BekahSeizureSense
//
//  Created by Bekah Muldoon on 11/12/25.
//

import SwiftUI

struct ThresholdViewBlue: View {
    @EnvironmentObject var settings: AppSettings

    enum HRMode: String, CaseIterable, Identifiable {
        case adaptive = "Adaptive Thresholding"
        case nonAdaptive = "Non-Adaptive Thresholding"
        var id: String { rawValue }
    }

    @State private var selectedHRMode: HRMode = .adaptive
    @State private var hrMinValue: Int = 60
    @State private var hrMaxValue: Int = 180
    @State private var sensitivityLevel = 5

    // Info sheet toggles
    @State private var showHRInfo = false
    @State private var showMovementInfo = false

    private var intFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .none
        return f
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Light blue background, adapts for dark mode
                (settings.theme == .light
                 ? Color(red: 0.85, green: 0.93, blue: 1.0)
                 : Color(red: 0.1, green: 0.12, blue: 0.18))
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20 * settings.textScale) {

                        Spacer().frame(height: 20)

                        // ----------------------------
                        // HR BOX
                        // ----------------------------
                        VStack(alignment: .leading, spacing: 15 * settings.textScale) {
                            HStack {
                                Text("HR Thresholding")
                                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button {
                                    showHRInfo = true
                                } label: {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20 * settings.textScale))
                                }
                            }

                            Picker("Mode", selection: $selectedHRMode) {
                                ForEach(HRMode.allCases) { mode in
                                    Text(mode.rawValue)
                                        .font(.system(size: 16 * settings.textScale))
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)

                            if selectedHRMode == .nonAdaptive {
                                HStack {
                                    Text("Min:")
                                        .font(.system(size: 16 * settings.textScale))
                                    TextField("Min", value: $hrMinValue, formatter: intFormatter)
                                        .textFieldStyle(.roundedBorder)
                                }

                                HStack {
                                    Text("Max:")
                                        .font(.system(size: 16 * settings.textScale))
                                    TextField("Max", value: $hrMaxValue, formatter: intFormatter)
                                        .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(settings.theme == .light ? Color.white : Color(.systemGray6))
                        )
                        .shadow(radius: 2)
                        .sheet(isPresented: $showHRInfo) {
                            VStack(spacing: 20) {
                                Text("Heart Rate Thresholding")
                                    .font(.title2)
                                    .bold()
                                Text("This controls how the app detects abnormal heart rates. Adaptive mode adjusts thresholds automatically, while Non-Adaptive uses fixed min and max values.")
                                    .padding()
                                Button("Close") { showHRInfo = false }
                                    .padding(.top, 20)
                            }
                            .presentationDetents([.medium])
                        }

                        // ----------------------------
                        // MOVEMENT BOX
                        // ----------------------------
                        VStack(alignment: .leading, spacing: 15 * settings.textScale) {
                            HStack {
                                Text("Movement Thresholding")
                                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                Button {
                                    showMovementInfo = true
                                } label: {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.blue)
                                        .font(.system(size: 20 * settings.textScale))
                                }
                            }

                            HStack {
                                Text("Sensitivity Level")
                                    .font(.system(size: 16 * settings.textScale))
                                Spacer()
                                Picker("", selection: $sensitivityLevel) {
                                    ForEach(1..<11) { level in
                                        Text("\(level)")
                                            .font(.system(size: 16 * settings.textScale))
                                            .tag(level)
                                    }
                                }
                                .pickerStyle(.menu)
                                .frame(width: 80)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(settings.theme == .light ? Color.white : Color(.systemGray6))
                        )
                        .shadow(radius: 2)
                        .sheet(isPresented: $showMovementInfo) {
                            VStack(spacing: 20) {
                                Text("Movement Thresholding")
                                    .font(.title2)
                                    .bold()
                                Text("This controls how sensitive the app is to movement. Higher sensitivity detects smaller movements, lower sensitivity requires larger movement events.")
                                    .padding()
                                Button("Close") { showMovementInfo = false }
                                    .padding(.top, 20)
                            }
                            .presentationDetents([.medium])
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Threshold Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
    }
}

#Preview {
    ThresholdViewBlue()
        .environmentObject(AppSettings())
}
