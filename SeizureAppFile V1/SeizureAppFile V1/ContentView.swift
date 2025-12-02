//
//  ContentView.swift
//  Seizure Sense UI
//
//  Created by Sarah Yonosh
//

import SwiftUI
import SwiftData
import Charts

struct ContentView: View {
    
    @State var showSettings = false
    @EnvironmentObject var settings: AppSettings
    
    @State var seizureDetected = false
    @State private var flash = false
    
    // Mock heart rate data
    struct HeartRateData: Identifiable {
        let id = UUID()
        let time: Int
        let bpm: Int
    }
    
    let mockHeartRate: [HeartRateData] = [
        HeartRateData(time: 0, bpm: 72),
        HeartRateData(time: 1, bpm: 75),
        HeartRateData(time: 2, bpm: 70),
        HeartRateData(time: 3, bpm: 80),
        HeartRateData(time: 4, bpm: 78),
        HeartRateData(time: 5, bpm: 74),
        HeartRateData(time: 6, bpm: 76)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background responding to light/dark mode
                (settings.theme == .light
                 ? Color(red: 0.85, green: 0.93, blue: 1.0)
                 : Color(red: 0.1, green: 0.12, blue: 0.18))
                .ignoresSafeArea()
                
                VStack(spacing: 20 * settings.textScale) {
                    Spacer()
                    
                    // Heart Rate Monitor
                    VStack(spacing: 12 * settings.textScale) {
                        Text("Heart Rate Monitor")
                            .font(.system(size: 20 * settings.textScale, weight: .bold))
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                        
                        Chart(mockHeartRate) {
                            LineMark(
                                x: .value("Time", $0.time),
                                y: .value("BPM", $0.bpm)
                            )
                            .foregroundStyle(.red)
                            .lineStyle(StrokeStyle(lineWidth: 3, lineJoin: .round))
                            
                            PointMark(
                                x: .value("Time", $0.time),
                                y: .value("BPM", $0.bpm)
                            )
                            .foregroundStyle(.red)
                        }
                        .frame(height: 180 * settings.textScale)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(settings.theme == .light ? Color.white : Color(.systemGray6))
                                .shadow(radius: 2)
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                    
                    // Seizure Button
                    Button("SEIZURE DETECTED") {
                        seizureDetected.toggle()
                    }
                    .font(.system(size: 36 * settings.textScale, weight: .bold))
                    .padding(.vertical, 20 * settings.textScale)
                    .frame(maxWidth: .infinity)
                    .background(
                        seizureDetected ?
                        (flash ? Color.red : Color.red.opacity(0.5)) :
                        (settings.theme == .light ? Color(.systemGray3) : Color(.systemGray5))
                    )
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
                    .onChange(of: seizureDetected) { _, newValue in
                        if newValue { startFlashing() }
                        else { stopFlashing() }
                    }
                    
                    Spacer()
                    
                    // Bottom buttons
                    HStack(spacing: 12 * settings.textScale) {
                        Button("ACCEPT") {}
                            .padding(.vertical, 10 * settings.textScale)
                            .frame(maxWidth: .infinity)
                            .background(settings.theme == .light ? Color(.systemBlue) : Color.blue.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        
                        Button("MUTE") {}
                            .padding(.vertical, 10 * settings.textScale)
                            .frame(maxWidth: .infinity)
                            .background(settings.theme == .light ? Color(.systemGray4) : Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        
                        Button("RAISE") {}
                            .padding(.vertical, 10 * settings.textScale)
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    Spacer()
                }
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .environmentObject(settings)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18 * settings.textScale, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 36 * settings.textScale, height: 36 * settings.textScale)
                    }
                    .padding(6 * settings.textScale)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(settings.theme == .light ? Color(.secondarySystemBackground) : Color(.systemGray5))
                            .frame(width: 56 * settings.textScale, height: 56 * settings.textScale)
                    )
                    .buttonStyle(RoundedSquareToolbarButtonStyle())
                }
            }
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
    }
    
    // MARK: - Flashing Animation
    func startFlashing() {
        flash = true
        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            flash.toggle()
        }
    }
    
    func stopFlashing() {
        flash = false
    }
}

// MARK: - Toolbar Button Style
struct RoundedSquareToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
        .environmentObject(AppSettings())
}
