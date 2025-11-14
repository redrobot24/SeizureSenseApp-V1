//
//  NotificationsView.swift
//  
//
//  Created by Sarah Yonosh on 11/13/25.
//  Edited by Isabella Smetana on 11/14/25
//
//

import SwiftUI

struct NotificationsView: View {
    
    @State private var seizureAlerts = true    // switch on/off
    @State private var heartRateAlerts = false
    @State private var fallDetection = false
    @State private var notificationType = 0           // Picker selection
    @State private var heartRateType = 0
    @State private var fallType = 0
    
    let types = ["Sound", "Vibrate", "Both"]  // Notification options
    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
               VStack(alignment: .leading, spacing: 12) {
                    
                    Toggle("Seizure Alerts", isOn: $seizureAlerts)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notification Type")
                            .font(.system(size: 16))
                        
                        Picker("Type", selection: $seizureType) {
                            ForEach(0..<types.count, id: \.self) { index in
                                Text(types[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
                
                
                // Heart Rate Alerts Card
                VStack(alignment: .leading, spacing: 12) {
                    
                    Toggle("Heart Rate Alerts", isOn: $heartRateAlerts)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notification Type")
                            .font(.system(size: 16))
                        
                        Picker("Type", selection: $heartRateType) {
                            ForEach(0..<types.count, id: \.self) { index in
                                Text(types[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
                
                
                // Fall Detection Alerts Card
                VStack(alignment: .leading, spacing: 12) {
                    
                    Toggle("Fall Detection", isOn: $fallDetection)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notification Type")
                            .font(.system(size: 16))
                        
                        Picker("Type", selection: $fallType) {
                            ForEach(0..<types.count, id: \.self) { index in
                                Text(types[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
                
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
    }
}