//
//  DataSharingView.swift
//  Maren-Content View
//
//  Created by Maren McCrossan on 11/12/25.
//
import SwiftUI
import UserNotifications
import CoreLocation

struct IconLabel: View {
    let title: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(color)
                Image(systemName: systemImage)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: 36, height: 36)

            Text(title)
                .foregroundStyle(.primary) // keep text not colorful
        }
    }
}


struct DataSharingView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("allowMessaging") private var allowMessaging = false
    @AppStorage("allowCellularData") private var allowCellularData = true
    @AppStorage("allowLocation") private var allowLocation = false
    @AppStorage("allowLocalNetwork") private var allowLocalNetwork = false
    @AppStorage("allowNotifications") private var allowNotifications = false
    @AppStorage("allowHealth") private var allowHealth = false
    @AppStorage("allowBackgroundRefresh") private var allowBackgroundRefresh = true

    var body: some View {
        NavigationStack {
            Form {
                Section("ALLOW SEIZURE SENSE TO ACCESS") {
                    Toggle(isOn: $allowMessaging) {
                        IconLabel(title: "Messaging", systemImage: "message", color: .green)
                            
                            
                    }

                    Toggle(isOn: $allowCellularData) {
                        IconLabel(title: "Cellular Data", systemImage: "antenna.radiowaves.left.and.right", color: .blue)
                    }

                    Toggle(isOn: $allowLocation) {
                        IconLabel(title: "Location", systemImage: "location", color: .red)
                    }

                    Toggle(isOn: $allowLocalNetwork) {
                        IconLabel(title: "Local Network", systemImage: "network", color: .purple)
                    }

                    Toggle(isOn: $allowNotifications) {
                        IconLabel(title: "Notifications", systemImage: "bell.badge", color: .orange)
                    }

                    Toggle(isOn: $allowHealth) {
                        IconLabel(title: "Health", systemImage: "heart.fill", color: .pink)
                    }

                    Toggle(isOn: $allowBackgroundRefresh) {
                        IconLabel(title: "Background App Refresh", systemImage: "arrow.clockwise", color: .teal)
                    }
                }
                
            }
            .navigationTitle("Data Sharing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
    }
}

#Preview {
    DataSharingView()
}
