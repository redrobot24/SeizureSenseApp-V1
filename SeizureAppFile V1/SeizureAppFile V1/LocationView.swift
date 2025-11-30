//
//  LocationSettingsView.swift
//  Seizure Sense UI
//
//  Created by Isabella Smetana on 11/30/25.
//

import SwiftUI
import CoreLocation

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
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        Form {
            Section(header: Text("Location Services")) {
                
                HStack {
                    Text("Enable Location Services")
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { locationManager.authorizationStatus == .authorizedWhenInUse || locationManager.authorizationStatus == .authorizedAlways },
                        set: { newValue in
                            if newValue {
                                locationManager.requestPermission()
                            } else {
                                // Direct user to system settings to disable
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                        }
                    ))
                    .labelsHidden()
                }
                
                HStack {
                    Text("Authorization Status")
                    Spacer()
                    Text(statusText(for: locationManager.authorizationStatus))
                        .foregroundColor(.gray)
                }
                
                if locationManager.authorizationStatus == .denied {
                    Button("Open Settings to Enable Location") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Location Services")
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
    }
}
