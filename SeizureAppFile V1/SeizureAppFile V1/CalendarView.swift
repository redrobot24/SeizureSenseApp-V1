//
//  CalendarView.swift
//  
//
//  Created by Kenzie MacGillivray on 11/30/25.
//

import SwiftUI
import Foundation
internal import Combine

class SeizureStore: ObservableObject {
    @Published var seizureDates: Set<Date> = []
    
    init() {
            loadSampleData()
        }

        func loadSampleData() {
            let calendar = Calendar.current
            
            // Example seizure dates
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
    let action: () -> Void
    
    var body: some View {
        Text("\(Calendar.current.component(.day, from: date))")
            .frame(maxWidth: .infinity, minHeight: 40)
            .padding(8)
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
    
    @ObservedObject var store: SeizureStore
    
    @State private var currentMonth = Date()
    
    var body: some View {
        let calendar = Calendar.current
        
        let monthInterval = calendar.dateInterval(of: .month, for: currentMonth)!
        let days = calendar.generateDates(
            inside: monthInterval,
            matching: DateComponents(hour: 0, minute: 0, second: 0)
        )
        
        VStack {
            NavigationStack{
                Text("Calendar")
                
                // --- CALENDAR TITLE ---
                //Text("Calendar")
                // .font(.largeTitle)
                // .bold()
                //.padding(.top)
                
                // MONTH HEADER
                HStack {
                    Button(action: { moveMonth(-1) }) {
                        Image(systemName: "chevron.left")
                    }
                    
                    Spacer()
                    
                    Text(monthFormatter.string(from: currentMonth))
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Button(action: { moveMonth(1) }) {
                        Image(systemName: "chevron.right")
                    }
                }
                .padding()
                
                // WEEKDAY LABELS
                HStack {
                    ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                        Text(day).frame(maxWidth: .infinity)
                    }
                }
                
                // DAYS GRID
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7)) {
                    ForEach(days, id: \.self) { day in
                        DayCell(
                            date: day,
                            isSelected: store.hasSeizure(on: day)
                        ) {
                            store.toggleSeizure(on: day)
                        }
                        .opacity(calendar.isDate(day, equalTo: currentMonth, toGranularity: .month) ? 1.0 : 0.2)
                    }
                }
            }
            .padding()
        }
    }
        func moveMonth(_ offset: Int) {
            if let newMonth = Calendar.current.date(byAdding: .month, value: offset, to: currentMonth) {
                currentMonth = newMonth
            }
        }
    }
    
    private let monthFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MMMM yyyy"
        return df
    }()
    
