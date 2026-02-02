import Foundation
import HealthKit
import Combine

// MARK: - Model
struct HeartRatePoint: Identifiable {
    let id = UUID()
    let time: Date
    let bpm: Int
}

@MainActor
final class HeartRateStream: ObservableObject {

    @Published var latestBPM: Int = 0
    @Published var series: [HeartRatePoint] = []

    private let reader = HeartRateReader()
    private let maxPoints = 120

    func start() {
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()
                HealthKitManager.shared.enableBackgroundDelivery()

                reader.start { [weak self] samples in
                    guard let self else { return }

                    // ✅ Explicit hop to MainActor
                    Task { @MainActor in
                        self.handle(samples)
                    }
                }

            } catch {
                print("HealthKit authorization error:", error)
            }
        }
    }

    func stop() {
        reader.stop()
    }

    private func handle(_ samples: [HKQuantitySample]) {
        let unit = HKUnit.count().unitDivided(by: .minute())

        for sample in samples.sorted(by: { $0.endDate < $1.endDate }) {
            let bpm = Int(sample.quantity.doubleValue(for: unit).rounded())

            latestBPM = bpm
            series.append(
                HeartRatePoint(time: sample.endDate, bpm: bpm)
            )

            if series.count > maxPoints {
                series.removeFirst(series.count - maxPoints)
            }
        }
    }
}
