//
//  AppSettings.swift
//  Seizure Sense UI
//
//  Created by Maren McCrossan on 12/1/25.
//

import SwiftUI
import Combine

enum Theme: String {
    case light, dark
}

class AppSettings: ObservableObject {
    @Published var theme: Theme = .light
    @Published var textScale: CGFloat = 1.0
}
