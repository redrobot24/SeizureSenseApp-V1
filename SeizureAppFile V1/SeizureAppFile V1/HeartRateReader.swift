//
//  HeartRateReader.swift
//  
//
//  Created by Maren McCrossan on 1/15/26.
//
import Foundation
import HealthKit

final class HeartRateReader {
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    private var anchor: HKQueryAnchor?
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var observerQuery: HKObserverQuery?

    func start(onSamples: @escaping ([HKQuantitySample]) -> Void) {
        // Observer for new samples
        let observer = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completion, error in
            guard error == nil else { completion(); return }
            self?.runAnchoredQuery(onSamples: onSamples) {
                completion()
            }
        }
        healthStore.execute(observer)
        observerQuery = observer

        // Initial load + attach live updates
        runAnchoredQuery(onSamples: onSamples, completion: {})
    }

    func stop() {
        if let q = anchoredQuery { healthStore.stop(q) }
        if let q = observerQuery { healthStore.stop(q) }
        anchoredQuery = nil
        observerQuery = nil
    }

    private func runAnchoredQuery(onSamples: @escaping ([HKQuantitySample]) -> Void, completion: @escaping () -> Void) {
        let startDate = Calendar.current.date(byAdding: .hour, value: -4, to: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: [])

        let query = HKAnchoredObjectQuery(type: heartRateType,
                                          predicate: predicate,
                                          anchor: anchor,
                                          limit: HKObjectQueryNoLimit) { [weak self] _, newSamples, _, newAnchor, error in
            guard error == nil else { completion(); return }
            self?.anchor = newAnchor
            if let samples = newSamples as? [HKQuantitySample] {
                onSamples(samples)
            }
            completion()
        }

        query.updateHandler = { [weak self] _, newSamples, _, newAnchor, _ in
            self?.anchor = newAnchor
            if let samples = newSamples as? [HKQuantitySample] {
                onSamples(samples)
            }
        }

        healthStore.execute(query)
        anchoredQuery = query
    }
}

