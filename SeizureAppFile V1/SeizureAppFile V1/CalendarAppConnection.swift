//
//  CalendarAppConnection.swift
//  
//
//  Created by Kenzie MacGillivray on 11/30/25.
//
import SwiftUI

@main
struct CalendarUIApp: App {
    @StateObject var store = SeizureStore()
    var body: some Scene {
        WindowGroup {
            CalendarView(store: store)
        }
    }
}
