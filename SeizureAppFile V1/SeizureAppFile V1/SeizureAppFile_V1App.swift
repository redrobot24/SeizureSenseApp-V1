//
//  SeizureAppFile_V1App.swift
//  SeizureAppFile V1
//
//  Created by Bekah Muldoon on 11/5/25.
//

import SwiftUI

//@main
//struct SeizureAppFile_V1App: App {
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
 //   }
//}

import SwiftData

@main
struct SeizureAppFile_V1App: App{
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
