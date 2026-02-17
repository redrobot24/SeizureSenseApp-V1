//
//  HeartRateStream.swift
//  Maren-View
//

import Foundation
import Combine
import HealthKit

// MARK: - Heart Rate Data Point
struct HeartRatePoint: Identifiable {
    let id = UUID()
    let time: Date
    let bpm: Int
}

// MARK: - Heart Rate Stream
final class HeartRateStream: ObservableObject {
    
    @Published var series: [HeartRatePoint] = []
    // UI-observed state (must update on MainActor)
    @Published private(set) var latestBPM: Int = 0
    
    private let healthStore = HKHealthStore()
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!

    private var anchor: HKQueryAnchor?
    private var query: HKAnchoredObjectQuery?

    private let maxPoints = 120

    // MARK: - Start Streaming
    func start() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: anchor,
            limit: HKObjectQueryNoLimit
        ) { [weak self] _, samples, _, newAnchor, error in
            guard let self else { return }
            self.anchor = newAnchor
            self.process(samples)
        }

        query.updateHandler = { [weak self] _, samples, _, newAnchor, _ in
            guard let self else { return }
            self.anchor = newAnchor
            self.process(samples)
        }

        self.query = query
        healthStore.execute(query)
    }
    // MARK: - Authorization + Start
    func ensureAuthorizedThenStart() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        let typesToRead: Set = [heartRateType]

        healthStore.requestAuthorization(toShare: [], read: typesToRead) { [weak self] success, error in
            if success {
                DispatchQueue.main.async {
                    self?.start()
                }
            } else {
                print("❌ HealthKit authorization failed:", error?.localizedDescription ?? "Unknown error")
            }
        }
    }


    // MARK: - Stop Streaming
    func stop() {
        if let query {
            healthStore.stop(query)
        }
        query = nil
    }

    // MARK: - Process Samples (background-safe)
    private func process(_ samples: [HKSample]?) {
        guard let samples = samples as? [HKQuantitySample] else { return }

        let unit = HKUnit.count().unitDivided(by: .minute())

        let points = samples
            .sorted { $0.endDate < $1.endDate }
            .map {
                HeartRatePoint(
                    time: $0.endDate,
                    bpm: Int($0.quantity.doubleValue(for: unit).rounded())
                )
            }

        guard !points.isEmpty else { return }

        // 🔑 Hop to MainActor ONLY for UI state updates
        Task { @MainActor in
            for point in points {
                self.latestBPM = point.bpm
                self.series.append(point)
                // Inside HeartRateStream when you append a new point
                print("Appending HR sample:", point.bpm, "at", point.time)
            }

            if self.series.count > self.maxPoints {
                self.series.removeFirst(self.series.count - self.maxPoints)
            }

            print("HR updated:", self.latestBPM)
        }
    }
}
