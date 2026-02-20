import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject var settings: AppSettings

    @State private var seizureAlerts = true
    @State private var heartRateAlerts = false
    @State private var fallDetection = false
    @State private var notificationType = 0
    @State private var heartRateType = 0
    @State private var fallType = 0

    let types = ["Sound", "Vibrate", "Both"]

    var body: some View {
        ZStack {
            (settings.theme == .light ? Color(red: 0.85, green: 0.93, blue: 1.0) : Color.black)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24 * settings.textScale) {
                    alertCard(title: "Seizure Alerts", isOn: $seizureAlerts, selectedType: $notificationType)
                    alertCard(title: "Heart Rate Alerts", isOn: $heartRateAlerts, selectedType: $heartRateType)
                    alertCard(title: "Fall Detection", isOn: $fallDetection, selectedType: $fallType)
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func alertCard(title: String, isOn: Binding<Bool>, selectedType: Binding<Int>) -> some View {
        VStack(alignment: .leading, spacing: 12 * settings.textScale) {
            Toggle(title, isOn: isOn)
                .font(.system(size: 18 * settings.textScale, weight: .medium))

            VStack(alignment: .leading, spacing: 8 * settings.textScale) {
                Text("Notification Type")
                    .font(.system(size: 16 * settings.textScale))
                Picker("Type", selection: selectedType) {
                    ForEach(0..<types.count, id: \.self) { index in
                        Text(types[index]).tag(index)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(settings.theme == .light ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
        )
    }
}

#Preview {
    NavigationStack {
        NotificationsView()
            .environmentObject(AppSettings())
    }
}
