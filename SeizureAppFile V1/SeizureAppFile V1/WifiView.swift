import SwiftUI

struct WifiView: View {
    @EnvironmentObject var settings: AppSettings

    @State private var wifiEnabled = true
    @State private var connectedNetwork = "Home_WiFi_5G"
    @State private var networks = ["Home_WiFi_2G", "eduroam", "Guest_WiFi", "Sarah's Hotspot"]

    var body: some View {
        ZStack {
            (settings.theme == .light ? Color(red: 0.85, green: 0.93, blue: 1.0) : Color.black)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24 * settings.textScale) {
                    wifiToggleCard
                    connectedNetworkCard
                    networksList
                    forgetButton
                    refreshButton
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Wi-Fi")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var wifiToggleCard: some View {
        HStack {
            Text("Wi-Fi")
                .font(.system(size: 20 * settings.textScale, weight: .semibold))
            Spacer()
            Toggle("", isOn: $wifiEnabled)
                .labelsHidden()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }

    private var connectedNetworkCard: some View {
        VStack(alignment: .leading, spacing: 6 * settings.textScale) {
            Text("Connected")
                .font(.system(size: 16 * settings.textScale, weight: .medium))
                .foregroundColor(.gray)

            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.blue)
                Text(connectedNetwork)
                    .font(.system(size: 18 * settings.textScale, weight: .medium))
                Spacer()
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
            .padding(.vertical, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }

    private var networksList: some View {
        VStack(alignment: .leading, spacing: 10 * settings.textScale) {
            Text("Available Networks")
                .font(.system(size: 16 * settings.textScale, weight: .medium))
                .foregroundColor(.gray)

            ForEach(networks, id: \.self) { network in
                Button {
                    connectedNetwork = network
                } label: {
                    HStack {
                        Image(systemName: "wifi")
                            .foregroundColor(.blue)
                        Text(network)
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

    private var forgetButton: some View {
        Button(role: .destructive) {
            connectedNetwork = ""
        } label: {
            Text("Forget This Network")
                .font(.system(size: 18 * settings.textScale, weight: .medium))
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                )
        }
    }

    private var refreshButton: some View {
        Button {
            networks.shuffle()
        } label: {
            Text("Refresh Networks")
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
        WifiView()
            .environmentObject(AppSettings())
    }
}
