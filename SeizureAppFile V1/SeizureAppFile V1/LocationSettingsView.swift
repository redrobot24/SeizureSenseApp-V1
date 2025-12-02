//
//  LocationSettingsView.swift
//  SeizureAppFile V1
//
//  Created by Maren McCrossan on 12/2/25.
//
import SwiftUI
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    override init() {
        super.init()
        manager.delegate = self
        checkAuthorization()
    }
    
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func checkAuthorization() {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}

struct LocationSettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Form {
            Section(header: Text("Location Services")
                        .font(.system(size: 16 * settings.textScale, weight: .semibold))) {
                
                HStack {
                    Text("Enable Location Services")
                        .font(.system(size: 16 * settings.textScale))
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: {
                            locationManager.authorizationStatus == .authorizedWhenInUse ||
                            locationManager.authorizationStatus == .authorizedAlways
                        },
                        set: { newValue in
                            if newValue {
                                locationManager.requestPermission()
                            } else {
#if canImport(UIKit)
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
#endif
                            }
                        }
                    ))
                    .labelsHidden()
                }
                .padding(.vertical, 4 * settings.textScale)
                
                HStack {
                    Text("Authorization Status")
                        .font(.system(size: 16 * settings.textScale))
                    Spacer()
                    Text(statusText(for: locationManager.authorizationStatus))
                        .foregroundColor(.gray)
                        .font(.system(size: 16 * settings.textScale))
                }
                .padding(.vertical, 4 * settings.textScale)
                
                if locationManager.authorizationStatus == .denied {
                    Button("Open Settings to Enable Location") {
#if canImport(UIKit)
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
#endif
                    }
                    .foregroundColor(.blue)
                    .font(.system(size: 16 * settings.textScale))
                }
            }
        }
        .navigationTitle("Location Services")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(preferredScheme(for: settings.theme))
    }
    
    private func preferredScheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    func statusText(for status: CLAuthorizationStatus) -> String {
        switch status {
        case .authorizedAlways: return "Always"
        case .authorizedWhenInUse: return "When In Use"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        case .notDetermined: return "Not Determined"
        @unknown default: return "Unknown"
        }
    }
}

#Preview {
    NavigationStack {
        LocationSettingsView()
            .environmentObject(AppSettings())
    }
}

