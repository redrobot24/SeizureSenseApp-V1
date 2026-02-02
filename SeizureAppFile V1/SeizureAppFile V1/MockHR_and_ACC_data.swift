//
//  MockHR_and_ACC_data.swift
//  Maren-View
//
//  Created by Maren McCrossan on 1/21/26.
//
import Foundation
import CoreMotion
import HealthKit

final class MockHR_and_ACC_data {
    // ACC
    private let TimeInterval = 1.0 / 50.0 // 50 Hz or 20ms
    private let accelSpikeDeltaG: Double = 1.5 // change in g magnitude considered a spike
    private let absoluteMagnitudeThreshold: Double = 3.0 // absolute g magnitude considered a spike
    private let alignmentWindow: TimeInterval = 5.0 // seconds to wait between spike notifications
    private let minimumSamplesForDelta: Int = 3
    //HR
    private let hrAbsoluteThreshold = 80
    private let hrSpikeDelta = 10
    //Managers
    private let motionManager = CMMotionManager()
    private let healthStore = HKHealthStore()
    // state variables
    private var lastAccelSample: (time: TimeInterval, g: Double)?
    private var lastHR: (time: TimeInterval, bpm: Int)?
    private var accelSpikeTimes: [TimeInterval] = []
    private var hrSpikeTimes: [TimeInterval] = []
    //Start detection
    func start() {
        startAccelerometer()
        startHeartRate()
    }
    //Accelerometer Motion
    private func startAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }
        motionManager.accelerometerUpdateInterval = 0.02 //50Hz
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data,_ in
            guard let self = self, let data = data else { return }
            let g = sqrt(
                data.acceleration.x * data.acceleration.x +
                data.acceleration.y * data.acceleration.y +
                data.acceleration.z * data.acceleration.z
            )
            let time = Date().timeIntervalSince1970
            if let last = self.lastAccelSample {
                let deltaG = abs(g - last.g)
                if deltaG >= self.accelSpikeDeltaG || g >= self.absoluteMagnitudeThreshold {
                    self.accelSpikeTimes.append(time)
            }
        }
            self.lastAccelSample = (time, g)
            self.checkForSeizure()
        }
    }
    //Heart Rate
    private func startHeartRate() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let predicate = HKQuery.predicateForSamples(
            withStart: Date(), end: nil, options: .strictStartDate)
        let query = HKAnchoredObjectQuery(
            type: hrType,
            predicate: predicate,
            anchor: nil,
            limit: HKObjectQueryNoLimit)
        {[weak self]_, samples,_,_,_ in self?.handleHRSamples(samples)}
        query.updateHandler = { [weak self] _, samples, _, _, _ in self?.handleHRSamples(samples)}
        healthStore.execute(query)
        }
    private func handleHRSamples(_ samples: [HKSample]?) {
        guard let hrSamples = samples as? [HKQuantitySample] else { return }
        
        for sample in hrSamples {
            let bpm = Int(sample.quantity.doubleValue(for: HKUnit(from: "count/min")))
            let time = sample.startDate.timeIntervalSince1970
            
            if let last = lastHR {
                let deltaHR = bpm - last.bpm
                if deltaHR >= hrSpikeDelta || bpm >= hrAbsoluteThreshold {
                    hrSpikeTimes.append(time) }
            }
        lastHR = (time, bpm)
        checkForSeizure()
                    }
                }
    //Combination of Accel & HR
    private func checkForSeizure() {
        for aTime in accelSpikeTimes {
            for hTime in hrSpikeTimes {
                if abs(aTime - hTime) <= alignmentWindow {
                    triggerSeizureDetected()
                    accelSpikeTimes.removeAll()
                    hrSpikeTimes.removeAll()
                    return
            }
        }
    }
            }
            // Detection Event
    private func triggerSeizureDetected() {
        print("Seizure Detected!")
    }
    }

