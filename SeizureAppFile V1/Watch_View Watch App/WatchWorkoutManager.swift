//
//  WatchWorkoutManager.swift
//  Maren-View
//
//  Created by Maren McCrossan on 2/3/26.
//

import Foundation
import HealthKit
import WatchConnectivity
import Combine

class WatchWorkoutManager: NSObject, HKLiveWorkoutBuilderDelegate, ObservableObject {
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?

    func startWorkout() {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            builder = session?.associatedWorkoutBuilder()
            builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            builder?.delegate = self
            session?.startActivity(with: Date())
            builder?.beginCollection(withStart: Date(), completion: { _,_ in })
        } catch {
            print("Could not start workout: \(error)")
        }
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        if collectedTypes.contains(HKQuantityType.quantityType(forIdentifier: .heartRate)!) {
            let hrUnit = HKUnit.count().unitDivided(by: .minute())
            if let statistics = workoutBuilder.statistics(for: HKQuantityType.quantityType(forIdentifier: .heartRate)!),
               let value = statistics.mostRecentQuantity()?.doubleValue(for: hrUnit) {
                print("Watch HR = \(value)")
                sendHeartRate(Int(value))
            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        // Required delegate method - empty implementation
    }

    func sendHeartRate(_ bpm: Int) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["bpm": bpm], replyHandler: nil, errorHandler: nil)
        }
    }
}
