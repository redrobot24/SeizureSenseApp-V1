import SwiftUI
import Combine

class SeizureStore: ObservableObject {
    @Published var seizureDates: Set<Date> = []
    
    init() {
        loadSampleData()
    }
    
    func loadSampleData() {
        let calendar = Calendar.current
        seizureDates.insert(calendar.date(from: DateComponents(year: 2025, month: 11, day: 3))!)
        seizureDates.insert(calendar.date(from: DateComponents(year: 2025, month: 11, day: 12))!)
        seizureDates.insert(calendar.date(from: DateComponents(year: 2025, month: 11, day: 22))!)
    }
    
    func toggleSeizure(on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if seizureDates.contains(day) {
            seizureDates.remove(day)
        } else {
            seizureDates.insert(day)
        }
    }
    
    func hasSeizure(on date: Date) -> Bool {
        let day = Calendar.current.startOfDay(for: date)
        return seizureDates.contains(day)
    }
}

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let textScale: CGFloat
    let action: () -> Void
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .font(.system(size: 16 * textScale, weight: .medium))
            .frame(maxWidth: .infinity, minHeight: 40 * textScale)
            .padding(6 * textScale)
            .background(isSelected ? Color.red.opacity(0.7) : Color.clear)
            .clipShape(Circle())
            .onTapGesture { action() }
    }
}

extension Calendar {
    func generateDates(
        inside interval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates: [Date] = []
        enumerateDates(startingAfter: interval.start,
                       matching: components,
                       matchingPolicy: .nextTime) { date, _, stop in
            guard let date = date else { return }
            if date < interval.end {
                dates.append(date)
            } else {
                stop = true
            }
        }
        return dates
    }
}

struct CalendarView: View {
    @EnvironmentObject var settings: AppSettings
    @ObservedObject var store: SeizureStore
    @Environment(\.colorScheme) var colorScheme  // <--- ADDED
    
    @State private var currentMonth = Date()
    
    private let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic background:
                (settings.theme == .light
                 ? Color(red: 0.85, green: 0.93, blue: 1.0)
                 : Color(red: 0.1, green: 0.12, blue: 0.18))
                .ignoresSafeArea()
                VStack(spacing: 16 * settings.textScale) {
                    Text("Calendar")
                        .font(.system(size: 28 * settings.textScale, weight: .bold))
                        .padding(.top, 16)
                    
                    // Month Navigation
                    HStack {
                        Button(action: { moveMonth(-1) }) {
                            Image(systemName: "chevron.left")
                        }
                        
                        Spacer()
                        
                        Text(monthFormatter.string(from: currentMonth))
                            .font(.system(size: 20 * settings.textScale, weight: .semibold))
                        
                        Spacer()
                        
                        Button(action: { moveMonth(1) }) {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .padding(.horizontal)
                    
                    // Weekday Labels
                    HStack {
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                            Text(day)
                                .font(.system(size: 14 * settings.textScale, weight: .medium))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Days Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(monthDays(), id: \.self) { day in
                            DayCell(
                                date: day,
                                isSelected: store.hasSeizure(on: day),
                                textScale: settings.textScale,
                                action: { store.toggleSeizure(on: day) }
                            )
                            .opacity(Calendar.current.isDate(day, equalTo: currentMonth, toGranularity: .month) ? 1.0 : 0.2)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .preferredColorScheme(settings.theme == .light ? .light : .dark)
    }
    
    private func monthDays() -> [Date] {
        let calendar = Calendar.current
        let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)!
        return calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
    }
    
    private func moveMonth(_ offset: Int) {
        if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
            currentMonth = newMonth
        }
    }
}

#Preview {
    CalendarView(store: SeizureStore())
        .environmentObject(AppSettings())
}
