
//


//  BluetoothView.swift
//
//
//  Created by Sarah Yonosh on 11/7/25.
//

import SwiftUI

struct BluetoothView: View {
    
    
    
    // switch for if Bluetooth is on
    @State private var bluetoothEnabled = true
    
    // list of discoverable devices
    @State private var availableDevices = [
        "Kenzie's Apple Watch",
        "Maren's Apple Watch",
        "Fitbit Charge 6",
        "Old Apple Watch Series 4"
    ]
    
    // Currently connected device
    @State private var connectedDevice: String? = "Sierra’s Apple Watch"
    
    var body: some View {
        ZStack {
            
            // Background (matches your app's theme)
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Bluetooth ON/OFF switch
                    bluetoothToggleCard
                    
                    // Currently connected device
                    connectedDeviceCard
                    
                    // List of all other devices
                    availableDevicesList
                    
                    // Disconnect button
                    disconnectButton
                    
                    // Refresh button
                    refreshButton
                }
                .padding()
            }
        }
        .navigationTitle("Bluetooth")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension BluetoothView {
    
    // switch that turns bluetooth on/off
    var bluetoothToggleCard: some View {
        HStack {
            
            Text("Bluetooth")
                .font(.system(size: 20, weight: .semibold))
            
            Spacer()
            
            Toggle("", isOn: $bluetoothEnabled)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    
    
    // shows the device that is currently cpnnected and actively sending seizure data
    var connectedDeviceCard: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            Text("Connected Device")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            if let device = connectedDevice {
                
                HStack {
                    Image(systemName: "applewatch")
                        .foregroundColor(.blue)
                    
                    Text(device)
                        .font(.system(size: 18, weight: .medium))
                    
                    Spacer()
                    
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green) // shows connection
                }
                .padding(.vertical, 4)
                
            } else {
                
                // No device connected fallback
                Text("No device connected")
                    .font(.system(size: 18))
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    
    
    // List of wearables the user could switch to.
    var availableDevicesList: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            Text("Available Devices")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            // Loop through each mock device
            ForEach(availableDevices, id: \.self) { device in
                
                Button {
                    // when a device is tapped, connects to it
                    connectedDevice = device
                } label: {
                    
                    HStack {
                        
                        // Icon changes depending on device type
                        Image(systemName:
                                device.contains("Fitbit")
                                ? "figure.walk.circle"
                                : "applewatch"
                        )
                        .foregroundColor(.blue)
                        
                        Text(device)
                            .font(.system(size: 18))
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                
                Divider()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }
    
    
    // unpairs the current watch.
    var disconnectButton: some View {
        Button(role: .destructive) {
            connectedDevice = nil
        } label: {
            Text("Disconnect Device")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
        }
    }
    
    
    // refresh bluetooth options
    // Simulates scanning for new devices by shuffling the list
    var refreshButton: some View {
        Button {
            //just shuffles order
            availableDevices.shuffle()
            
            
        } label: {
            Text("Scan for Devices")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
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
        BluetoothView()
    }
}



