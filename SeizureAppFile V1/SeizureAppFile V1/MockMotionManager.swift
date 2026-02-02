import Foundation

/// A mock motion manager simulating accelerometer magnitude data with occasional seizure spike bursts.
/// Callbacks and API mirror the expected MotionManager interface.
public class MockMotionManager {
    public static let shared = MockMotionManager()

    /// Called once at the start of each simulated seizure spike burst.
    public var onSeizureSpike: (() -> Void)?

    private var timer: Timer?
    private var spikeActive = false
    private var spikeStartTime: Date?

    private init() {}

    /// Starts the mock motion updates.
    /// Fires every 0.2 seconds with normal small random noise values around 0.05-0.15 g.
    /// Every ~10 seconds a spike burst lasting ~2 seconds occurs with magnitude 2.0-3.0 g.
    /// Calls onSeizureSpike once at the start of the spike burst.
    public func start() {
        guard timer == nil else { return }

        spikeActive = false
        spikeStartTime = nil

        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            let now = Date()

            if let spikeStart = self.spikeStartTime {
                // During spike burst (~2 seconds)
                let elapsed = now.timeIntervalSince(spikeStart)
                if elapsed < 2.0 {
                    // Spike magnitude between 2.0 and 3.0 g with some variability
                    _ = Double.random(in: 2.0...3.0)
                    // (In a real app, here would be code to feed this spikeMagnitude to listeners)
                } else {
                    // End spike burst
                    self.spikeActive = false
                    self.spikeStartTime = nil
                    // After spike ends, normal random noise continues
                    // (No callback here)
                }
            } else {
                // Not currently in spike burst
                _ = Double.random(in: 0.05...0.15)
                // (In a real app, here would be code to feed this normalMagnitude to listeners)

                // Chance to start a spike burst roughly every 10 seconds
                // Timer fires every 0.2s, so probability ~0.2/10 = 0.02 per tick
                if Double.random(in: 0..<1) < 0.02 {
                    self.spikeActive = true
                    self.spikeStartTime = now
                    self.onSeizureSpike?()
                }
            }
        }
    }

    /// Stops the mock motion updates and resets internal state.
    public func stop() {
        timer?.invalidate()
        timer = nil
        spikeActive = false
        spikeStartTime = nil
    }
}
