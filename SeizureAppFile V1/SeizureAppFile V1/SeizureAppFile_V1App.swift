//
//  SeizureAppFile_V1App.swift
//  SeizureAppFile V1
//
//  Created by Bekah Muldoon on 11/5/25.
//

import SwiftUI

@main
struct SeizureSenseApp: App {
    
    @StateObject private var settings = AppSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .preferredColorScheme(colorScheme(for: settings.theme))
        }
    }
    
    private func colorScheme(for theme: Theme) -> ColorScheme? {
        switch theme {
        case .light: return .light
        case .dark: return .dark
        }
    }
}
