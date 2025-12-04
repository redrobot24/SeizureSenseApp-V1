import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var settings: AppSettings
    
    @ObservedObject var seizureStore = SeizureStore()

    var body: some View {
        NavigationStack {
            ZStack {
                (settings.theme == .light ? Color(red: 0.85, green: 0.93, blue: 1.0) : Color.black)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 16 * settings.textScale) {   // <-- reduced spacing
                        
                        // Appearance & Text Size
                        VStack(spacing: 16 * settings.textScale) {   // <-- reduced spacing
                            
                            // Appearance Card
                            VStack(alignment: .leading, spacing: 8 * settings.textScale) {
                                Text("Appearance")
                                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                                    .foregroundColor(settings.theme == .light ? .black : .white)
                                
                                Picker("Appearance", selection: $settings.theme) {
                                    Text("Light").tag(Theme.light)
                                    Text("Dark").tag(Theme.dark)
                                }
                                .pickerStyle(.segmented)
                            }
                            .padding(12 * settings.textScale)     // <-- reduced padding
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                            )
                            
                            // Text Size Card
                            VStack(alignment: .leading, spacing: 8 * settings.textScale) {
                                Text("Text Size")
                                    .font(.system(size: 20 * settings.textScale, weight: .bold))
                                    .foregroundColor(settings.theme == .light ? .black : .white)
                                
                                HStack {
                                    Text("A")
                                        .font(.system(size: 12 * settings.textScale))
                                    Slider(value: $settings.textScale, in: 0.8...1.6, step: 0.05)
                                    Text("A")
                                        .font(.system(size: 24 * settings.textScale))
                                }
                            }
                            .padding(12 * settings.textScale)     // <-- reduced padding
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                            )
                        }
                        .padding(.horizontal)
                        
                        //  Buttons Section
                        VStack(spacing: 12 * settings.textScale) {   // <-- reduced spacing
                            settingsButton(title: "Data Sharing", icon: "square.and.arrow.up") { DataSharingView() }
                            settingsButton(title: "Notifications", icon: "bell") { NotificationsView() }
                            settingsButton(title: "Location Services", icon: "location") { LocationSettingsView() }
                            settingsButton(title: "Alarm Settings", icon: "alarm") { AlarmView() }
                            settingsButton(title: "Messaging", icon: "message") { MessagingView() }
                            settingsButton(title: "Threshold Settings", icon: "slider.horizontal.3") { ThresholdViewBlue() }
                            settingsButton(title: "Calendar", icon: "calendar") { CalendarView(store: seizureStore) }
                            settingsButton(title: "Wi-Fi", icon: "wifi") { WifiView() }
                            settingsButton(title: "Bluetooth", icon: "bolt.horizontal") { BluetoothView() }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)   // <-- reduced
                    }
                    .padding(.top)
                    .padding(.bottom, 40)   // <-- ensures scroll space
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(settings.theme == .light ? .gray : .white)
                    }
                }
            }
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
    }
    
    // Reusable Settings Button
    func settingsButton<Destination: View>(
        title: String,
        icon: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()
            .environmentObject(settings)) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 18 * settings.textScale))  // <-- slightly smaller
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 17 * settings.textScale, weight: .medium))
                    .foregroundColor(settings.theme == .light ? .black : .white)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding(10 * settings.textScale)   // <-- reduced padding
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
            )
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(AppSettings())
    }
}
