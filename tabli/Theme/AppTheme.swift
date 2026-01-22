import SwiftUI
import UIKit

struct AppTheme {
    
    // MARK: - Dynamic Colors
    
    static func dynamicColor(light: String, dark: String) -> Color {
        return Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ?
                UIColor(hex: dark) :
                UIColor(hex: light)
        })
    }

    // Raw Palette (Dynamic)
    // Backgrounds: Light (Cream/Beige) -> Dark (Dark Grey/Brown)
    static let beigeLight = dynamicColor(light: "EDE0D4", dark: "2D241F")   // Wrapper/Card backgrounds
    static let beigeMedium = dynamicColor(light: "DDB892", dark: "4A3B32")  // Interactive elements
    static let brownMedium = dynamicColor(light: "B08968", dark: "A68A76")  // Secondary text/icons
    static let brownDark = dynamicColor(light: "7F5539", dark: "DDB892")    // Primary text/Active elements (Inverted for dark mode)
    static let ivory = dynamicColor(light: "F5F1EB", dark: "1C1917")        // Cards
    static let cream = dynamicColor(light: "F9F6F2", dark: "000000")        // Main Background
    
    
    // MARK: - Semantic Colors
    
    static let accent = brownDark
    static let background = cream
    static let cardBackground = ivory
    static let textPrimary = brownDark
    static let textSecondary = brownMedium
    
    
    // MARK: - Typography & Layout

    static let fontName = "SF Rounded"
    static let animationDuration: Double = 0.3
    static let springAnimation = Animation.spring(response: 0.4, dampingFraction: 0.7)
}

// MARK: - Extensions

extension Color {
    init(hex: String) {
        self.init(uiColor: UIColor(hex: hex))
    }
}

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
