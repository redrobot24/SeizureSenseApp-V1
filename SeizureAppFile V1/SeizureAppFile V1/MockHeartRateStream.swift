import Foundation
import Combine
import SwiftUI
import HealthKit

final class MockHeartRateStream: HeartRateStream {
    private var timer: Timer?

    override func start() {
        // Do not touch HealthKit; just simulate data.
        stop()
        // Seed a small series so the chart has something immediately.
        let now = Date()
        let seed = (0..<20).map { i in
            HeartRatePoint(time: now.addingTimeInterval(Double(-20 + i)), bpm: Int.random(in: 65...85))
        }
        DispatchQueue.main.async {
            self.series = seed
            self.latestBPM = seed.last?.bpm ?? 75
        }
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            let next = max(55, min(120, (self.latestBPM + Int.random(in: -3...3))))
            let point = HeartRatePoint(time: Date(), bpm: next)
            DispatchQueue.main.async {
                self.latestBPM = next
                self.series.append(point)
                if self.series.count > 120 {
                    self.series.removeFirst(self.series.count - 120)
                }
            }
        }
    }

    override func stop() {
        timer?.invalidate()
        timer = nil
    }
}
