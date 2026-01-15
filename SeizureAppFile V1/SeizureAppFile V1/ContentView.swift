//
//  ContentView.swift
//  Seizure Sense UI
//
//  Created by Sarah Yonosh
//

import SwiftUI
import SwiftData
import Charts

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

    // MARK: - Detection / Stabilization Tuning
    private let spikeRiseThreshold: Int = 20
    private let spikeWindowSeconds: TimeInterval = 10
    private let stabilizationVarianceThreshold: Double = 8
    private let stabilizationSustainSeconds: TimeInterval = 10

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

                    Spacer()

                    // MARK: - Bottom Buttons
                    HStack(spacing: 12 * settings.textScale) {
                        Button("ACCEPT") {}
                            .buttonStyle(BottomButtonStyle(color: .blue))

                        Button("MUTE") {}
                            .buttonStyle(BottomButtonStyle(color: .gray))

                        Button("RAISE") {}
                            .buttonStyle(BottomButtonStyle(color: .red))
                    }
                    .padding(.horizontal)

                    Spacer()
                    Spacer()
                }
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
        .onAppear { hrStream.start() }
        .onDisappear {
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
        let now = Date()
        let recent = hrStream.series.filter {
            now.timeIntervalSince($0.time) <= spikeWindowSeconds
        }

        guard let first = recent.first,
              let last = recent.last else { return }

        if (last.bpm - first.bpm) >= spikeRiseThreshold {
            registerSpike()
        }
    }

    // MARK: - Spike Registration
    func registerSpike() {
        lastSpikeTime = Date()
        seizureDetected = true
        startFlashingIfNeeded()
        startStabilizationMonitor()
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

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(color.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// MARK: - Preview
#Preview {
    ContentView(stream: MockHeartRateStream())
        .environmentObject(AppSettings())
}
