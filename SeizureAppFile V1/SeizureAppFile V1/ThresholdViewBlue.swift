//
//  ThresholdViewBlue.swift
//  BekahSeizureSense
//
//  Created by Bekah Muldoon on 11/12/25.
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

    
    @State private var showHRInfo = false
    @State private var showMovementInfo = false

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

                    Spacer()
                        .frame(height: 40)

                  
                    VStack(alignment: .leading, spacing: 15) {

                       
                        HStack(spacing: 6) {
                            Text("HR Thresholding")
                                .font(.headline)

                            Button {
                                showHRInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }

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
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 2)

                    
                    VStack(alignment: .leading, spacing: 15) {

                        
                        HStack(spacing: 6) {
                            Text("Movement Thresholding")
                                .font(.headline)

                            Button {
                                showMovementInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }

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

        
        .sheet(isPresented: $showHRInfo) {
            VStack(spacing: 20) {
                Text("HR Thresholding")
                    .font(.title2)
                    .bold()

                Text("""
HR (heart rate) thresholding helps to detect seizures by monitoring the user's heart rate.

• Adaptive mode learns the user's normal HR patterns, and can notice unusual changes in HR.   
• Non-adaptive mode uses fixed minimum and maximum HR values that are set manually.
""")
                .padding()

                Button("Close") {
                    showHRInfo = false
                }
                .padding(.top, 10)
            }
            .presentationDetents([.medium])
        }

        // ===== MOVEMENT INFO SHEET =====
        .sheet(isPresented: $showMovementInfo) {
            VStack(spacing: 20) {
                Text("Movement Thresholding")
                    .font(.title2)
                    .bold()

                Text("""
Movement thresholding uses accelerometer data from the Apple Watch to identify seizure-like shaking.

Higher sensitivity = detects smaller movements (higher number) 
Lower sensitivity = ignores mild movement and only triggers on strong shaking (lower number)
""")
                .padding()

                Button("Close") {
                    showMovementInfo = false
                }
                .padding(.top, 10)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ThresholdViewBlue()
}

