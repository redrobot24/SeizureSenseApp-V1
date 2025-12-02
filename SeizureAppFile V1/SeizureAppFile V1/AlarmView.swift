//
//  AlarmView.swift
//
//  Created by Kenzie MacGillivray on 11/13/25.
//

import SwiftUI

struct AlarmView: View {
    @EnvironmentObject var settings: AppSettings
    
    @State private var volume: Double = 50
    @State private var brightness: Double = 50
    private let range: ClosedRange<Double> = 0...100
    private let step: Double = 10
    
    @State private var showVolumeInfo = false
    @State private var showBrightnessInfo = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background for light/dark mode
                (settings.theme == .light
                 ? Color(red: 0.85, green: 0.93, blue: 1.0)
                 : Color(red: 0.1, green: 0.12, blue: 0.18))
                .ignoresSafeArea()
                
                VStack(spacing: 40 * settings.textScale) {
                    // Volume Section
                    VStack(spacing: 12 * settings.textScale) {
                        HStack(spacing: 6) {
                            Text("Volume \(Int(volume))%")
                                .font(.system(size: 18 * settings.textScale, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Button {
                                showVolumeInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            decreaseVol
                            Slider(value: $volume, in: range, step: step)
                            increaseVol
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    // Brightness Section
                    VStack(spacing: 12 * settings.textScale) {
                        HStack(spacing: 6) {
                            Text("Brightness \(Int(brightness))%")
                                .font(.system(size: 18 * settings.textScale, weight: .medium))
                                .foregroundColor(.primary)
                            
                            Button {
                                showBrightnessInfo = true
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.blue)
                            }
                        }
                        
                        HStack {
                            decreaseBtn
                            Slider(value: $brightness, in: range, step: step)
                            increaseBtn
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color(.systemGray6))
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle("Alarm Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
        // Volume Info Sheet
        .sheet(isPresented: $showVolumeInfo) {
            VStack(spacing: 20 * settings.textScale) {
                Text("Volume Settings")
                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                
                Text("""
The volume setting controls how loud the seizure alert sound will be.
""")
                .multilineTextAlignment(.center)
                .padding()
                
                Button("Close") {
                    showVolumeInfo = false
                }
                .padding(.top, 20)
            }
            .presentationDetents([.medium])
        }
        // Brightness Info Sheet
        .sheet(isPresented: $showBrightnessInfo) {
            VStack(spacing: 20 * settings.textScale) {
                Text("Brightness Settings")
                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                
                Text("""
The brightness setting controls how bright the flashing SEIZURE alert will appear in the event of a seizure.
""")
                .multilineTextAlignment(.center)
                .padding()
                
                Button("Close") {
                    showBrightnessInfo = false
                }
                .padding(.top, 20)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    AlarmView()
        .environmentObject(AppSettings())
}

// MARK: - Volume Controls
private extension AlarmView {
    func increaseV() {
        guard volume <= range.upperBound - step else { return }
        volume += step
    }
    func decreaseV() {
        guard volume >= range.lowerBound + step else { return }
        volume -= step
    }
    var increaseVol: some View {
        Button {
            withAnimation { increaseV() }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18))
        }
    }
    var decreaseVol: some View {
        Button {
            withAnimation { decreaseV() }
        } label: {
            Image(systemName: "minus")
                .font(.system(size: 18))
        }
    }
}

// MARK: - Brightness Controls
private extension AlarmView {
    func increaseB() {
        guard brightness <= range.upperBound - step else { return }
        brightness += step
    }
    func decreaseB() {
        guard brightness >= range.lowerBound + step else { return }
        brightness -= step
    }
    var increaseBtn: some View {
        Button {
            withAnimation { increaseB() }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 18))
        }
    }
    var decreaseBtn: some View {
        Button {
            withAnimation { decreaseB() }
        } label: {
            Image(systemName: "minus")
                .font(.system(size: 18))
        }
    }
}
