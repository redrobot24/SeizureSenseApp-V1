import Foundation
import CoreMotion

@MainActor
final class MotionManager {
    static let shared = MotionManager()

    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()
    private var mockTimer:Timer?
    var useMockData: Bool = true
    // Configuration
    struct Configuration {
        var updateInterval: TimeInterval = 1.0 / 50.0 // 50 Hz
        var spikeDeltaThreshold: Double = 1.5 // change in g magnitude considered a spike
        var absoluteMagnitudeThreshold: Double = 3.0 // absolute g magnitude considered a spike
        var debounceInterval: TimeInterval = 5.0 // seconds to wait between spike notifications
        var minimumSamplesForDelta: Int = 3 // number of samples to compute delta
    }

    var config = Configuration()

    // Callback to trigger when a spike is detected (hook this to your button action)
    var onSeizureSpike: (() -> Void)?

    // State
    private var recentMagnitudes: [Double] = []
    private var lastSpikeDate: Date?
    private var isRunning = false

    private init() {
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 1
    }

    func start() {
        guard !isRunning else { return }
        isRunning = true
        recentMagnitudes.removeAll(keepingCapacity: true)

        if useMockData {
            startMockAccelerometer()
        } else {
            startRealAccelerometer()
        }
    }
    private func startRealAccelerometer() {
        guard motionManager.isAccelerometerAvailable else { return }

        motionManager.accelerometerUpdateInterval = config.updateInterval

        motionManager.startAccelerometerUpdates(to: queue) { [weak self] data, _ in
            guard let self = self, let data = data else { return }
            self.handleAccelerometer(data)
        }
    }
    private func startMockAccelerometer() {
        let interval = config.updateInterval

        mockTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let ax = Double.random(in: -3.0...4.0)
            let ay = Double.random(in: -3.0...4.0)
            let az = Double.random(in: -3.0...4.0)

            let magnitude = sqrt(ax * ax + ay * ay + az * az)
            self.handleMockMagnitude(magnitude)
        }
    }


    func stop() {
        guard isRunning else { return }
        isRunning = false

        motionManager.stopAccelerometerUpdates()
        mockTimer?.invalidate()
        mockTimer = nil

        recentMagnitudes.removeAll()
    }


    private func handleAccelerometer(_ data: CMAccelerometerData) {
        // Compute g magnitude
        let ax = data.acceleration.x
        let ay = data.acceleration.y
        let az = data.acceleration.z
        let magnitude = sqrt(ax * ax + ay * ay + az * az)

        // Keep rolling buffer
        recentMagnitudes.append(magnitude)
        let maxCount = max(config.minimumSamplesForDelta, 5)
        if recentMagnitudes.count > maxCount { recentMagnitudes.removeFirst(recentMagnitudes.count - maxCount) }

        // Absolute threshold check
        let absoluteSpike = magnitude >= config.absoluteMagnitudeThreshold

        // Delta threshold check (compare current magnitude to mean of previous samples)
        var deltaSpike = false
        if recentMagnitudes.count >= config.minimumSamplesForDelta {
            let previous = recentMagnitudes.dropLast()
            if !previous.isEmpty {
                let meanPrev = previous.reduce(0, +) / Double(previous.count)
                let delta = abs(magnitude - meanPrev)
                deltaSpike = delta >= config.spikeDeltaThreshold
            }
        }

        if absoluteSpike || deltaSpike {
            notifySpikeIfNeeded()
        }
    }
    private func handleMockMagnitude(_ magnitude: Double) {
        recentMagnitudes.append(magnitude)

        let maxCount = max(config.minimumSamplesForDelta, 5)
        if recentMagnitudes.count > maxCount {
            recentMagnitudes.removeFirst(recentMagnitudes.count - maxCount)
        }

        let absoluteSpike = magnitude >= config.absoluteMagnitudeThreshold

        var deltaSpike = false
        if recentMagnitudes.count >= config.minimumSamplesForDelta {
            let previous = recentMagnitudes.dropLast()
            if !previous.isEmpty {
                let meanPrev = previous.reduce(0, +) / Double(previous.count)
                let delta = abs(magnitude - meanPrev)
                deltaSpike = delta >= config.spikeDeltaThreshold
            }
        }

        if absoluteSpike || deltaSpike {
            notifySpikeIfNeeded()
        }
    }


    private func notifySpikeIfNeeded() {
        // Debounce notifications
        let now = Date()
        if let last = lastSpikeDate, now.timeIntervalSince(last) < config.debounceInterval {
            return
        }
        lastSpikeDate = now
        // Ensure callback on main thread for UI safety
        //if let callback = onSeizureSpike {
          //  DispatchQueue.main.async {
          //      callback()
         //   }
        //}
    }
}
