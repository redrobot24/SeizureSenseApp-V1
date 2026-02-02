//
//  ContentView.swift
//  Seizure Sense UI
//
//  Created by Sarah Yonosh
//

import SwiftUI
import SwiftData
import Charts
import CoreMotion

struct ContentView: View {

    // MARK: - App State
    @State private var showSettings = false

    // MARK: - Chart
    @State private var chartScrollX: Date = Date()

    @State private var autoFollowLatest = true
    @EnvironmentObject var settings: AppSettings

    // MARK: - Alert / Seizure State
    @State private var seizureDetected = false
    @State private var isFlashing = false
    @State private var flashOpacity: Double = 1.0
    @State private var lastSpikeTime: Date?
    @State private var stabilizationTimer: Timer?

    @State private var motionMonitoringEnabled = true
    @State private var lastMotionSpike: Date?
    @State private var lastHRSpike: Date?

    // MARK: - Detection / Stabilization Tuning
    private let spikeRiseThreshold: Int = 20
    private let spikeWindowSeconds: TimeInterval = 10
    private let stabilizationVarianceThreshold: Double = 8
    private let stabilizationSustainSeconds: TimeInterval = 10
    private let coincidenceWindowSeconds: TimeInterval = 3

    // MARK: - Heart Rate
    private let providedStream: HeartRateStream?
    @StateObject private var hrStream: HeartRateStream

    init(stream: HeartRateStream? = nil) {
        self._hrStream = StateObject(wrappedValue: stream ?? HeartRateStream())
        self.providedStream = stream
    }

    // MARK: - UI
    var body: some View {
        NavigationStack {
            ZStack {

                // Background
                (settings.theme == .light
                 ? Color(red: 0.85, green: 0.93, blue: 1.0)
                 : Color(red: 0.1, green: 0.12, blue: 0.18))
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20 * settings.textScale) {
                        Spacer()

                        // MARK: - Heart Rate Monitor
                        VStack(spacing: 12 * settings.textScale) {
                            Text("Heart Rate Monitor")
                                .font(.system(size: 20 * settings.textScale, weight: .bold))

                            Chart(hrStream.series) {
                                LineMark(
                                    x: .value("Time", $0.time),
                                    y: .value("BPM", $0.bpm)
                                )
                                .foregroundStyle(.red)
                                .lineStyle(StrokeStyle(lineWidth: 3))

                                PointMark(
                                    x: .value("Time", $0.time),
                                    y: .value("BPM", $0.bpm)
                                )
                                .foregroundStyle(.red)
                            }
                            .chartScrollableAxes(.horizontal)
                            .chartScrollPosition(x: $chartScrollX)
                            .simultaneousGesture(
                                DragGesture().onChanged { _ in
                                    autoFollowLatest = false
                                }
                            )
                            .chartXScale(domain: visibleDomain())
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .second, count: 5)) {
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel(format: .dateTime.second(.twoDigits))
                                }
                            }
                            .chartYScale(domain: bpmDomain())
                            .chartYAxis {
                                let domain = bpmDomain()
                                let lower = Int(domain.lowerBound.rounded(.down))
                                let upper = Int(domain.upperBound.rounded(.up))
                                AxisMarks(
                                    values: Array(stride(from: lower, through: upper, by: 10))
                                ) {
                                    AxisGridLine()
                                    AxisTick()
                                    AxisValueLabel()
                                }
                            }
                            .chartYAxisLabel("BPM")
                            .frame(height: 180 * settings.textScale)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(settings.theme == .light ? .white : Color(.systemGray6))
                                    .shadow(radius: 2)
                            )
                            .padding(.horizontal)

                            Text("Current: \(hrStream.series.last?.bpm ?? 0) bpm")
                                .font(.system(size: 16 * settings.textScale, weight: .medium))
                                .foregroundColor(.secondary)

                            if !autoFollowLatest {
                                Button("Follow Live") {
                                    autoFollowLatest = true
                                    chartScrollX = latestSample?.time ?? Date()
                                }
                                .font(.footnote)
                                .buttonStyle(.borderedProminent)
                            }
                        }

                        // MARK: - Seizure Button
                        Button("SEIZURE DETECTED") {
                            registerSpike()
                        }
                        .font(.system(size: 36 * settings.textScale, weight: .bold))
                        .padding(.vertical, 20 * settings.textScale)
                        .frame(maxWidth: .infinity)
                        .background(
                            seizureDetected
                            ? Color.red.opacity(flashOpacity)
                            : (settings.theme == .light
                               ? Color(.systemGray3)
                               : Color(.systemGray5))
                        )
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                        
                        // Motion Monitoring Status
                        HStack {
                            Circle()
                                .fill(motionMonitoringEnabled ? Color.green : Color.red)
                                .frame(width: 10, height: 10)
                            Text(motionMonitoringEnabled ? "Motion Monitoring: On" : "Motion Monitoring: Off")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            if let t = lastMotionSpike {
                                Text(" • Last Spike: \(t.formatted(date: .omitted, time: .standard))")
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)

                        Spacer()

                        // MARK: - Bottom Buttons
                        HStack(spacing: 12 * settings.textScale) {
                            Button("ACCEPT") {
                                // You can define accept behavior here if needed in the future
                            }
                            .buttonStyle(BottomButtonStyle(color: .blue, textScale: settings.textScale))

                            Button("MUTE") {
                                // Stop the alert if active
                                if seizureDetected {
                                    DispatchQueue.main.async {
                                        stopAlert()
                                    }
                                }
                            }
                            .buttonStyle(BottomButtonStyle(color: .gray, textScale: settings.textScale))

                            Button("RAISE") {
                                // If not currently flashing, start the alert
                                if !isFlashing && !seizureDetected {
                                    registerSpike()
                                }
                            }
                            .buttonStyle(BottomButtonStyle(color: .red, textScale: settings.textScale))
                        }
                        .padding(.horizontal)

                        Spacer()
                        Spacer()
                    }
                }
                .padding(.vertical)
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                        .environmentObject(settings)
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 18 * settings.textScale))
                    }
                }
            }
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
        .onAppear {
            hrStream.start()
            // Hook motion spike to seizure button logic
            MotionManager.shared.onSeizureSpike = {
                DispatchQueue.main.async {
                    self.lastMotionSpike = Date()
                    self.evaluateCombinedSpike()
                }
            }
            MotionManager.shared.useMockData = true
            MotionManager.shared.start()
            motionMonitoringEnabled = true
        }
        .onDisappear {
            MotionManager.shared.stop()
            MotionManager.shared.onSeizureSpike = nil
            motionMonitoringEnabled = false

            hrStream.stop()
            stopStabilizationMonitor()
        }
        .onChange(of: hrStream.latestBPM) { _, _ in
            detectSpikeFromHeartRate()
            evaluateStabilization()

            if autoFollowLatest {
                chartScrollX = latestSample?.time ?? Date()
            }
        }
    }

    // MARK: - Helpers

    private var latestSample: HeartRatePoint? {
        hrStream.series.last
    }

    private func visibleDomain() -> ClosedRange<Date> {
        let end = latestSample?.time ?? Date()
        let paddedEnd = end.addingTimeInterval(2)
        let start = paddedEnd.addingTimeInterval(-60)
        return start...paddedEnd
    }

    private func bpmDomain() -> ClosedRange<Double> {
        let bpms = hrStream.series.map { Double($0.bpm) }
        guard let minBPM = bpms.min(),
              let maxBPM = bpms.max(),
              minBPM.isFinite,
              maxBPM.isFinite else {
            return 40...180
        }

        let padding = 10.0
        let lower = max(0, minBPM - padding)
        let upper = max(minBPM + padding * 2, maxBPM + padding)
        return lower...upper
    }

    // MARK: - Spike Detection
    func detectSpikeFromHeartRate() {
        //takes HR and time from last spike window
        let now = Date()
        let recent = hrStream.series.filter {
            now.timeIntervalSince($0.time) <= spikeWindowSeconds
        }

        guard let first = recent.first,
              let last = recent.last else { return }
        //subtract first and last HR value in window to compare to threshold
        if (last.bpm - first.bpm) >= spikeRiseThreshold {
            lastHRSpike = Date()
            evaluateCombinedSpike()
        }
    }

    // MARK: - Spike Registration
    func registerSpike() {
        lastSpikeTime = Date()
        seizureDetected = true
        startFlashingIfNeeded()
        startStabilizationMonitor()
    }

    // MARK: - Combined Spike Evaluation
    func evaluateCombinedSpike() {
        let now = Date()

        // Check if HR spike happened recently
        guard let hrTime = lastHRSpike, now.timeIntervalSince(hrTime) <= coincidenceWindowSeconds else { return }

        // Check if motion spike happened recently
        guard let motionTime = lastMotionSpike, now.timeIntervalSince(motionTime) <= coincidenceWindowSeconds else { return }

        // Both spikes are recent → trigger seizure
        lastHRSpike = nil
        lastMotionSpike = nil
        registerSpike()

        // Automatically stop flashing after 2 seconds (or adjust as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            stopAlert()
        }
    }


    // MARK: - Flashing Control
    func startFlashingIfNeeded() {
        guard !isFlashing else { return }

        isFlashing = true
        flashOpacity = 1.0

        withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
            flashOpacity = 0.4
        }
    }

    // MARK: - Stabilization Logic
    func startStabilizationMonitor() {
        stabilizationTimer?.invalidate()
        stabilizationTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: true
        ) { _ in
            evaluateStabilization()
        }
    }

    func stopStabilizationMonitor() {
        stabilizationTimer?.invalidate()
        stabilizationTimer = nil
    }

    func evaluateStabilization() {
        guard seizureDetected else { return }

        let window = max(spikeWindowSeconds, stabilizationSustainSeconds)
        let now = Date()
        let recent = hrStream.series.filter {
            now.timeIntervalSince($0.time) <= window
        }

        guard recent.count >= 5 else { return }

        let bpms = recent.map { Double($0.bpm) }
        let mean = bpms.reduce(0, +) / Double(bpms.count)
        let variance = bpms.map { pow($0 - mean, 2) }.reduce(0, +) / Double(bpms.count)
        let stddev = sqrt(variance)

        if stddev <= stabilizationVarianceThreshold {
            if hasBeenStableFor(
                atLeast: stabilizationSustainSeconds,
                threshold: stabilizationVarianceThreshold
            ) {
                stopAlert()
            }
        }
    }

    func hasBeenStableFor(atLeast seconds: TimeInterval, threshold: Double) -> Bool {
        let now = Date()
        let recent = hrStream.series.filter {
            now.timeIntervalSince($0.time) <= seconds
        }

        guard recent.count >= 5 else { return false }

        let bpms = recent.map { Double($0.bpm) }
        let mean = bpms.reduce(0, +) / Double(bpms.count)
        let variance = bpms.map { pow($0 - mean, 2) }.reduce(0, +) / Double(bpms.count)
        let stddev = sqrt(variance)

        return stddev <= threshold
    }

    func stopAlert() {
        stopStabilizationMonitor()
        lastSpikeTime = nil
        seizureDetected = false
        isFlashing = false

        withAnimation(.none) {
            flashOpacity = 1.0
        }
    }
}

// MARK: - Button Style
struct BottomButtonStyle: ButtonStyle {
    let color: Color
    let textScale: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 16 * textScale, weight: .semibold))
            .padding(.vertical, 10 * textScale)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(configuration.isPressed ? 0.7 : 1))
            )
            .foregroundStyle(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(
                        colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.05),
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Preview
#Preview {
    ContentView(stream: HeartRateStream())
        .environmentObject(AppSettings())
}

