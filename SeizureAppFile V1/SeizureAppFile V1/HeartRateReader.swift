import Foundation
import HealthKit

final class HeartRateReader: NSObject {

    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    // Anchored query storage
    private var heartRateQuery: HKAnchoredObjectQuery?
    private var anchor: HKQueryAnchor?

    // Observer query for background delivery
    private var observerQuery: HKObserverQuery?

    // Silent workout session
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    // MARK: - Start reading HR
    func start(onUpdate: @escaping ([HKQuantitySample]) -> Void) {

        // 1️⃣ Enable background delivery
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { success, error in
            if let error = error {
                print("Background delivery error: \(error)")
            } else {
                print("Background delivery enabled: \(success)")
            }
        }

        // 2️⃣ Start silent workout session
        startWorkoutSession()

        // 3️⃣ Observer query to detect new HR samples
        observerQuery = HKObserverQuery(sampleType: heartRateType, predicate: nil) { [weak self] _, completionHandler, error in
            if let error = error {
                print("Observer query error: \(error)")
                completionHandler()
                return
            }

            self?.fetchNewSamples(onUpdate: onUpdate)
            completionHandler()
        }

        if let observerQuery = observerQuery {
            healthStore.execute(observerQuery)
        }

        // 4️⃣ Fetch initial data
        fetchNewSamples(onUpdate: onUpdate)
    }

    // MARK: - Stop reading HR
    func stop() {
        if let query = heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }

        if let query = observerQuery {
            healthStore.stop(query)
            observerQuery = nil
        }

        workoutSession?.stopActivity(with: Date())
        workoutSession?.end()
        workoutSession = nil
        workoutBuilder = nil
    }

    // MARK: - Silent workout session
    private func startWorkoutSession() {
        let config = HKWorkoutConfiguration()
        config.activityType = .other
        config.locationType = .indoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutBuilder = workoutSession!.associatedWorkoutBuilder()

            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)
            workoutSession?.delegate = self

            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { _, _ in
                print("Workout collection started")
            }

        } catch {
            print("Error starting workout session: \(error)")
        }
    }

    // MARK: - Fetch new HR samples
    private func fetchNewSamples(onUpdate: @escaping ([HKQuantitySample]) -> Void) {
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            onUpdate(samples as? [HKQuantitySample] ?? [])
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            self?.anchor = newAnchor
            onUpdate(samples as? [HKQuantitySample] ?? [])
        }

        heartRateQuery = query
        healthStore.execute(query)
    }
}

// MARK: - HKWorkoutSessionDelegate
extension HeartRateReader: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        // Optional: handle session state changes
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        print("Workout session error: \(error)")
    }
}
