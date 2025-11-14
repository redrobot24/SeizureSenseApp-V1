//
//  WifiView.swift
//  
//
//
// wifi settings page
//
//Created by Sarah Yonosh on 11/7/25.



import SwiftUI

struct WifiView: View {
    
    // variables
    // switch for whether Wi-Fi is on
    @State private var wifiEnabled = true
    
    // The currently connected network (mock for now)
    @State private var connectedNetwork = "Home_WiFi_5G"
    
    // List of available networks (mock data)
    // In the future these would come from Apple’s Network framework or device settings permissions
    @State private var networks = ["Home_WiFi_2G", "eduroam", "Guest_WiFi", "Sarah's Hotspot"]

    
    var body: some View {
        ZStack {
            
            Color(red: 0.85, green: 0.93, blue: 1.0)
                .ignoresSafeArea()
            
            // scroll in case list of networks is long
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Wi-Fi ON/OFF switch
                    wifiToggleCard
                    
                    // The currently connected Wi-Fi network
                    connectedNetworkCard
                    
                    // List of other networks available
                    networksList

                    // Button that gets rid of network
                    forgetButton

                    // Button that simulates “refreshing” network scan
                    refreshButton
                }
                .padding()
            }
        }
        .navigationTitle("Wi-Fi")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension WifiView {

    // wifi swtich
    // top row w switch
    //
    var wifiToggleCard: some View {
        HStack {
            
            
            Text("Wi-Fi")
                .font(.system(size: 20, weight: .semibold))
            
            Spacer()
            
            // When the switch moves, wifiEnabled changes
            Toggle("", isOn: $wifiEnabled)
                .labelsHidden()  //
        }
        .padding()
        // Rounded white background matching other settings cards
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }

    
    // Connected
    // what wifi is currently connected
    // (Mocked for now)
    var connectedNetworkCard: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            
            Text("Connected")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
            
            HStack {
                
                Image(systemName: "wifi")
                    .foregroundColor(.blue)
                
                
                Text(connectedNetwork)
                    .font(.system(size: 18, weight: .medium))
                
                Spacer()
                
                //check its connected
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }

    
    // available networks
    // other wifi networks available
    // Tapping any of these changes the connected network.
    var networksList: some View {
        VStack(alignment: .leading, spacing: 10) {
            
            
            Text("Available Networks")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)

            
            ForEach(networks, id: \.self) { network in
                
                
                Button {
                    // When tapped, change connected network
                    // In the future this could show a password prompt
                    connectedNetwork = network
                } label: {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.blue)
                        
                        Text(network)
                            .font(.system(size: 18))
                        
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                
                // Divider line between each network row
                Divider()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.7))
        )
    }

    
    //forget network
    var forgetButton: some View {
        Button(role: .destructive) {
            
            // removes the connected network (mock behavior)
            connectedNetwork = ""
            
        } label: {
            Text("Forget This Network")
                .font(.system(size: 18, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.7))
                )
        }
    }

    
    // refresh
    // just switched order for now
    var refreshButton: some View {
        Button {
            
            // this swaps the order randomly — a fake "refresh"
            networks.shuffle()
            
        } label: {
            Text("Refresh Networks")
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
        WifiView()
    }
}

