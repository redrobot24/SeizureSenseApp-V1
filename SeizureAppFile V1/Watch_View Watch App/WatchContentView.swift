import SwiftUI

struct WatchContentView: View {

    @StateObject var manager = WatchHealthKitManager()

    var body: some View {
        VStack(spacing: 20) {

            Text("Heart Rate")
                .font(.headline)

            Text("\(Int(manager.heartRate)) BPM")
                .font(.largeTitle)
                .foregroundColor(.red)

            Button("Start Monitoring") {
                manager.startWorkout()
            }

            Button("Stop") {
                manager.stopWorkout()
            }
        }
    }
}
