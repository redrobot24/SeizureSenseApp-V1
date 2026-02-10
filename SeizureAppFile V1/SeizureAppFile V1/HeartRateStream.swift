import Foundation
import HealthKit
import Combine

struct HeartRatePoint: Identifiable {
    let id = UUID()
    let time: Date
    let bpm: Int
}

@MainActor
final class HeartRateStream: ObservableObject {

    @Published var latestBPM: Int = 0
    @Published var series: [HeartRatePoint] = []

    // Optional chart scroll property
    @Published var chartScrollX: Date = Date()

    private let reader = HeartRateReader()
    private let maxPoints = 120

    // Auto-follow the latest point on chart
    var autoFollowLatest: Bool = true

    // Throttle console logs to avoid flooding
    private var lastLogTime: Date = Date(timeIntervalSince1970: 0)
    private let logThrottleInterval: TimeInterval = 1.0 // seconds

    // MARK: - Start streaming
    func start() {
        Task {
            do {
                try await HealthKitManager.shared.requestAuthorization()

                reader.start { [weak self] samples in
                    guard let self else { return }

                    Task { @MainActor in
                        for sample in samples {
                            let bpm = Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())).rounded())
                            self.latestBPM = bpm
                            self.series.append(HeartRatePoint(time: sample.endDate, bpm: bpm))

                            // Keep only most recent points
                            if self.series.count > self.maxPoints {
                                self.series.removeFirst(self.series.count - self.maxPoints)
                            }

                            // Auto-scroll chart
                            if self.autoFollowLatest, let last = self.series.last {
                                self.chartScrollX = last.time
                            }

                            // Throttled console log
                            let now = Date()
                            if now.timeIntervalSince(self.lastLogTime) >= self.logThrottleInterval {
                                print("Latest BPM: \(self.latestBPM), series count: \(self.series.count)")
                                self.lastLogTime = now
                            }
                        }
                    }
                }

            } catch {
                print("HealthKit authorization error:", error)
            }
        }
    }

    // MARK: - Stop streaming
    func stop() {
        reader.stop()
    }
}
