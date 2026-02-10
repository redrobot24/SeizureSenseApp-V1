//
//  PhoneConnectivityManager.swift
//  Maren-View
//
//  Created by Maren McCrossan on 2/3/26.
//

import Foundation
import WatchConnectivity
import Combine

class PhoneConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var latestBPM: Int = 0

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Int {
            DispatchQueue.main.async {
                self.latestBPM = bpm
                // Optionally, append to your HeartRateStream here
                print("Received HR from Watch: \(bpm)")
            }
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
}
