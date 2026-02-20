//
//  WatchHeartRateManager.swift
//  SeizureAppFile V1
//
//  Created by Maren McCrossan on 2/20/26.

//
import Foundation
import HealthKit
import WatchConnectivity
import Combine

@MainActor
class WatchHeartRateManager: NSObject, ObservableObject, WCSessionDelegate {
    //var objectWillChange: ObservableObjectPublisher
    

    private let healthStore = HKHealthStore()
    private var query: HKAnchoredObjectQuery?
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    @Published var heartRate: Double = 0

    override init() {
        super.init()
        activateSession()
        requestAuthorization()
    }

    private func activateSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }

    private func requestAuthorization() {
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) {[weak self] success, _ in
            guard let self = self else { return }
            
            if success {
                Task {@MainActor in
                    self.startQuery()}
            }
        }
    }

    private func startQuery() {

        query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, _, _ in
            guard let self = self else { return }
            
            Task {@MainActor in
                self.handle(samples: samples)}
        }

        query?.updateHandler = { [weak self] _, samples, _, _, _ in
            guard let self = self else { return }
            
            Task {@MainActor in
                self.handle(samples: samples)}
        }

        if let query = query {
            healthStore.execute(query)
        }
    }

    private func handle(samples: [HKSample]?) {
        guard let sample = samples?.first as? HKQuantitySample else { return }

        let bpm = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
        DispatchQueue.main.async {
            self.heartRate = bpm
        }

        sendToPhone(bpm: bpm)
    }

    private func sendToPhone(bpm: Double) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil)
        }
    }

    // Required delegate stubs
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}
}


