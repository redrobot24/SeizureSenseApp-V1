//
//  WatchConnectivityManager.swift
//  Maren-View
//
//  Created by Maren McCrossan on 2/10/26.
//
import Foundation
import WatchConnectivity
import Combine

@MainActor
final class WatchConnectivityManager: NSObject, ObservableObject {
    @Published var isPhoneAppInstalled: Bool = false
    @Published var isReachable: Bool = false
    @Published var lastBPM: Int? = nil
    @Published var receivingData: Bool = false

    private var receiveTimer: Timer?

    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            updateState(from: session)
        }
    }

    private func updateState(from session: WCSession) {
        isPhoneAppInstalled = session.isCompanionAppInstalled // watchOS side API
        isReachable = session.isReachable
    }

    // A small helper to briefly show a “receiving” indicator
    private func pulseReceiving() {
        receivingData = true
        receiveTimer?.invalidate()
        let timer = Timer(timeInterval: 1.0, repeats: false) { [weak self] _ in
            // Explicitly state we’re on the MainActor for the mutation
            MainActor.assumeIsolated {
                self?.receivingData = false
            }
        }
        receiveTimer = timer
        RunLoop.main.add(timer, forMode: .common)
    }
}

extension WatchConnectivityManager: WCSessionDelegate {
    // watchOS activation callback
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("watchOS WCSession activation error:", error)
        } else {
            print("watchOS WCSession activated:", activationState.rawValue)
        }
        updateState(from: session)
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        updateState(from: session)
    }

    // Receive immediate messages from phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let bpm = message["bpm"] as? Int {
            lastBPM = bpm
            pulseReceiving()
        } else if let status = message["status"] as? String {
            print("Received status:", status)
            pulseReceiving()
        }
    }

    // Receive background-safe userInfo from phone
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let bpm = userInfo["bpm"] as? Int {
            lastBPM = bpm
            pulseReceiving()
        } else if let status = userInfo["status"] as? String {
            print("Received status:", status)
            pulseReceiving()
        }
    }
}
