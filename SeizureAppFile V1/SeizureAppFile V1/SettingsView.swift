//
//  SettingsView.swift
//  Seizure Sense UI
//
//  Created by Sarah Yonosh on 11/7/25.
//

import SwiftUI
import Charts
import SwiftData

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
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
        ZStack {
            // Calm light blue background
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Heart Rate Monitor Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Heart Rate Monitor")
                            .font(.headline)
                            .padding(.horizontal)
                        
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
                        .frame(height: 180)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.6))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    
                    // Settings Buttons Section
                    VStack(spacing: 16) {
                        settingsButton(title: "Data Sharing", icon: "square.and.arrow.up"){
                            DataSharingView()
                        }
                        settingsButton(title: "Messaging", icon: "message"){
                            MessagingView()
                        }
                        settingsButton(title: "Notifications", icon: "bell"){
                            NotificationsView()
                        }
                        settingsButton(title: "Alarm Settings", icon: "alarm"){
                            AlarmView()
                        }
                        settingsButton(title: "Threshold Settings", icon: "slider.horizontal.3"){
                            ThresholdViewBlue()
                        }
                        settingsButton(title: "Wi-Fi", icon: "wifi"){
                            WifiView()
                        }
                        settingsButton(title: "Bluetooth", icon: "bolt.horizontal"){
                            BluetoothView()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            
        }
        
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            // X button in the top-right corner
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    // Reusable button view
    //view builder destination so clicking can take you anywhere
    func settingsButton<Destination: View>(title: String, icon: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink(destination: destination()) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 32)
                Text(title)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.7))
            )
        }
    }
}
    
    #Preview {
        NavigationStack {
            SettingsView()
        }
    }

