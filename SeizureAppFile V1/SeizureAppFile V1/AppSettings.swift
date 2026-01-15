import SwiftUI
import Combine

// MARK: - Theme Enum
enum Theme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { rawValue }
    
    // Computed colors for consistent usage
    var backgroundColor: Color {
        switch self {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        case .system:
            return Color(UIColor.systemBackground)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .light:
            return Color.black
        case .dark:
            return Color.white
        case .system:
            return Color.primary
        }
    }
    
    var secondaryColor: Color {
        switch self {
        case .light:
            return Color.gray
        case .dark:
            return Color.gray.opacity(0.7)
        case .system:
            return Color.secondary
        }
    }
}

class AppSettings: ObservableObject {
    @Published var theme: Theme = .system
    @Published var textScale: CGFloat = 1.0
}
