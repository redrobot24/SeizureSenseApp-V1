//
//  ContentView.swift
//  Watch-View Watch App
//
//  Created by Maren McCrossan on 2/3/26.
//

import SwiftUI

struct WatchContentView: View {
    @StateObject private var connectivity = WatchConnectivityManager()

    var body: some View {
        VStack(spacing: 8) {
            // iPhone app installed status
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.isPhoneAppInstalled ? Color.green : Color.red)
                    .frame(width: 8, height: 8)
                Text(connectivity.isPhoneAppInstalled ? "iPhone App Installed" : "iPhone App Missing")
                    .font(.footnote)
            }

            // Reachability status
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.isReachable ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                Text(connectivity.isReachable ? "Reachable" : "Not Reachable")
                    .font(.footnote)
            }

            Divider()

            // Data indicator
            HStack(spacing: 6) {
                Circle()
                    .fill(connectivity.receivingData ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                Text(connectivity.receivingData ? "Receiving Data" : "Idle")
                    .font(.footnote)
            }

            if let bpm = connectivity.lastBPM {
                Text("Last BPM: \(bpm)")
                    .font(.headline)
                    .padding(.top, 4)
            } else {
                Text("Awaiting BPM…")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    WatchContentView()
}
