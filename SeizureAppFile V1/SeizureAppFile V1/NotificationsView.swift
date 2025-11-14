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
    
    let types = ["Sound", "Vibrate", "Both"]  // Notification options
    
    var body: some View {
        ZStack {
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                Text("Notifications")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 20)
                
                // Seizure Alerts on/off
                Toggle("Seizure Alerts", isOn: $seizureAlerts)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
                     // MARK: - Heart Rate Alerts Toggle
                Toggle("Heart Rate Alerts", isOn: $heartRateAlerts)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
                
                // MARK: - Fall Detection Toggle
                Toggle("Fall Detection", isOn: $fallDetection)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.7))
                    )
                
                // Notification Type Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notification Type")
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                    
                    Picker("Type", selection: $notificationType) {
                        ForEach(0..<types.count, id: \.self) { index in
                            Text(types[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
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

