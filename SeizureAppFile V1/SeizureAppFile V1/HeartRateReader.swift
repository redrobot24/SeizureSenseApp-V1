import Foundation
import HealthKit

final class HeartRateReader {

    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    private var anchor: HKQueryAnchor?
    private var anchoredQuery: HKAnchoredObjectQuery?
    private var observerQuery: HKObserverQuery?

    func start(onSamples: @escaping ([HKQuantitySample]) -> Void) {

        // Create ONE anchored query for live updates
        let startDate = Calendar.current.date(byAdding: .hour, value: -4, to: Date())
        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: nil,
            options: []
        )

        let anchored = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: predicate,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            guard error == nil else { return }
            self?.anchor = newAnchor
            if let samples = samples as? [HKQuantitySample] {
                Task { @MainActor in
                    onSamples(samples)
                }
            }
        }

        anchored.updateHandler = { [weak self] _, samples, _, newAnchor, error in
            guard error == nil else { return }
            self?.anchor = newAnchor
            if let samples = samples as? [HKQuantitySample] {
                Task { @MainActor in
                    onSamples(samples)
                }
            }
        }

        healthStore.execute(anchored)
        anchoredQuery = anchored

        // Observer just wakes HealthKit (does NOT create queries)
        let observer = HKObserverQuery(
            sampleType: heartRateType,
            predicate: nil
        ) { _, completion, _ in
            completion()
        }

        healthStore.execute(observer)
        observerQuery = observer
    }

    func stop() {
        if let anchoredQuery {
            healthStore.stop(anchoredQuery)
        }
        if let observerQuery {
            healthStore.stop(observerQuery)
        }
        anchoredQuery = nil
        observerQuery = nil
    }
}
