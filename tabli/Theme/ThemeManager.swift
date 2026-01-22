import SwiftUI
import Combine

/// Manager for handling app theme preferences (Light/Dark mode)
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    /// Theme options available in the app
    enum Theme: String, CaseIterable {
        case system = "Sistem"
        case light = "Açık"
        case dark = "Koyu"
        
        var colorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        var icon: String {
            switch self {
            case .system: return "circle.lefthalf.filled"
            case .light: return "sun.max.fill"
            case .dark: return "moon.fill"
            }
        }
    }
    
    @Published var currentTheme: Theme {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: "appTheme")
            applyTheme()
        }
    }
    
    private init() {
        if let savedTheme = UserDefaults.standard.string(forKey: "appTheme"),
           let theme = Theme(rawValue: savedTheme) {
            self.currentTheme = theme
        } else {
            self.currentTheme = .system
        }
    }
    
    /// Apply the selected theme to all windows
    func applyTheme() {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            
            for window in windowScene.windows {
                switch self.currentTheme {
                case .system:
                    window.overrideUserInterfaceStyle = .unspecified
                case .light:
                    window.overrideUserInterfaceStyle = .light
                case .dark:
                    window.overrideUserInterfaceStyle = .dark
                }
            }
        }
    }
    
    /// Get the current color scheme based on theme setting
    var colorScheme: ColorScheme? {
        return currentTheme.colorScheme
    }
}

// MARK: - View Extension for Theme

extension View {
    /// Apply theme-aware styling to views
    func themedBackground() -> some View {
        self.background(AppTheme.background)
    }
    
    func themedCard() -> some View {
        self
            .background(AppTheme.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
