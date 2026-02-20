import Foundation
import HealthKit

final class HealthKitManager {
    static let shared = HealthKitManager()
    private let healthStore = HKHealthStore()

    private init() {}

    private var heartRateType: HKQuantityType {
        HKQuantityType.quantityType(forIdentifier: .heartRate)!
    }

    func requestAuthorization() async throws {
        let readTypes: Set = [heartRateType]
        try await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func enableBackgroundDelivery() {
        healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate) { _, _ in }
    }
}
