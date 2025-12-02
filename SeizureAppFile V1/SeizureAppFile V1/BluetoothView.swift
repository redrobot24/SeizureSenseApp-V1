import SwiftUI

struct BluetoothView: View {
    
    @EnvironmentObject var settings: AppSettings

    @State private var bluetoothEnabled = true
    @State private var availableDevices = [
        "Kenzie's Apple Watch",
        "Maren's Apple Watch",
        "Fitbit Charge 6",
        "Old Apple Watch Series 4"
    ]
    @State private var connectedDevice: String? = "Sierra’s Apple Watch"
    
    var body: some View {
        ZStack {
            (settings.theme == .light ? Color(red: 0.85, green: 0.93, blue: 1.0) : Color.black)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24 * settings.textScale) {
                    bluetoothToggleCard
                    connectedDeviceCard
                    availableDevicesList
                    disconnectButton
                    refreshButton
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Bluetooth")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension BluetoothView {
    
    var bluetoothToggleCard: some View {
        HStack {
            Text("Bluetooth")
                .font(.system(size: 20 * settings.textScale, weight: .semibold))
            
            Spacer()
            
            Toggle("", isOn: $bluetoothEnabled)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }
    
    var connectedDeviceCard: some View {
        VStack(alignment: .leading, spacing: 6 * settings.textScale) {
            Text("Connected Device")
                .font(.system(size: 16 * settings.textScale, weight: .medium))
                .foregroundColor(.gray)
            
            if let device = connectedDevice {
                HStack {
                    Image(systemName: "applewatch")
                        .foregroundColor(.blue)
                    Text(device)
                        .font(.system(size: 18 * settings.textScale, weight: .medium))
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
                .padding(.vertical, 4)
            } else {
                Text("No device connected")
                    .font(.system(size: 18 * settings.textScale))
                    .foregroundColor(.red)
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }
    
    var availableDevicesList: some View {
        VStack(alignment: .leading, spacing: 10 * settings.textScale) {
            Text("Available Devices")
                .font(.system(size: 16 * settings.textScale, weight: .medium))
                .foregroundColor(.gray)
            
            ForEach(availableDevices, id: \.self) { device in
                Button {
                    connectedDevice = device
                } label: {
                    HStack {
                        Image(systemName: device.contains("Fitbit") ? "figure.walk.circle" : "applewatch")
                            .foregroundColor(.blue)
                        Text(device)
                            .font(.system(size: 18 * settings.textScale))
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
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }
    
    var disconnectButton: some View {
        Button(role: .destructive) {
            connectedDevice = nil
        } label: {
            Text("Disconnect Device")
                .font(.system(size: 18 * settings.textScale, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                )
        }
    }
    
    var refreshButton: some View {
        Button {
            availableDevices.shuffle()
        } label: {
            Text("Scan for Devices")
                .font(.system(size: 18 * settings.textScale, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                )
        }
    }
}

#Preview {
    NavigationStack {
        BluetoothView()
            .environmentObject(AppSettings())
    }
}
