import HealthKit

final class HeartRateReader {

    private let store = HKHealthStore()
    private let type = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    private var anchor: HKQueryAnchor?
    private var query: HKAnchoredObjectQuery?

    func start(onUpdate: @escaping ([HKQuantitySample]) -> Void) {

        query = HKAnchoredObjectQuery(
            type: type,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            guard let self else { return }
            self.anchor = newAnchor
            onUpdate(samples as? [HKQuantitySample] ?? [])
        }

        query?.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }
            self.anchor = newAnchor
            onUpdate(samples as? [HKQuantitySample] ?? [])
        }

        store.execute(query!)
    }

    func stop() {
        if let query {
            store.stop(query)
        }
        query = nil
    }
}
