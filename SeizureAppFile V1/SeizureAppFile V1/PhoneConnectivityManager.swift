//
//  PhoneConnectivityManager.swift
//  Maren-View
//
//  Created by Maren McCrossan on 2/3/26.
//

import Foundation
import WatchConnectivity
import Combine

@MainActor
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
            latestBPM=bpm
            HeartRateStream.shared.receiveLiveBPM(bpm)
                print("Received HR from Watch: \(bpm)")
            
        }
    }
    func session(_ session: WCSession,
                 didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let bpm = userInfo["bpm"] as? Int {
            latestBPM = bpm
            HeartRateStream.shared.receiveLiveBPM(bpm)
            print("Background HR received:", bpm)
        }
    }
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    func session(_ session: WCSession,
                     activationDidCompleteWith activationState: WCSessionActivationState,
                     error: Error?) {

            if let error = error {
                print("WC activation error:", error)
            } else {
                print("WC activated:", activationState.rawValue)
            }
        }
    
}
