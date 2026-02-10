//
//  WatchHealthKitManager.swift
//  Maren-View
//
//  Created by Maren McCrossan on 2/3/26.
//
import Foundation
import HealthKit

class WatchHealthKitManager {
    let healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let types: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        healthStore.requestAuthorization(toShare: [], read: types, completion: completion)
    }
}
