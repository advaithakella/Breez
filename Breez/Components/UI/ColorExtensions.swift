import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Breez Color Palette
extension Color {
    // Brand Colors
    static let orange = SwiftUI.Color(hex: "FFCC8E")
    static let blue = SwiftUI.Color(hex: "7DC7FF")
    static let cream = SwiftUI.Color(hex: "D0CAB6")
    
    // Primary colors
    static let breezOrange = SwiftUI.Color(hex: "FFCC8E")
    static let breezBlue = SwiftUI.Color(hex: "7DC7FF")
    static let breezCream = SwiftUI.Color(hex: "D0CAB6")
    
    // Background colors
    static let breezBackground = Color.white
    static let breezCardBackground = SwiftUI.Color(hex: "F5F3F0") // Light cream
    static let breezSurface = SwiftUI.Color(hex: "F5F3F0")
    
    // Text colors
    static let breezText = Color.black
    static let breezSubtext = Color.black.opacity(0.7)
    static let breezSecondaryText = Color.black.opacity(0.5)
    
    // Border and accent colors
    static let breezBorder = SwiftUI.Color(hex: "D0CAB6")
    static let breezAccent = SwiftUI.Color(hex: "D0CAB6")
    
    // System colors
    static let primary = SwiftUI.Color(hex: "FFCC8E")
    static let text = Color.black
    static let deactiveText = SwiftUI.Color(hex: "D0CAB6").opacity(0.7)
    static let deactive = SwiftUI.Color(hex: "D0CAB6").opacity(0.5)
    static let background = Color.white
    static let subtext = Color.black.opacity(0.7)
    static let blockColor = SwiftUI.Color(hex: "D0CAB6").opacity(0.3)
    static let cardBackground = SwiftUI.Color(hex: "F5F3F0")
    static let borderColor = SwiftUI.Color(hex: "D0CAB6")
    static let stroke = SwiftUI.Color(hex: "D0CAB6")
    static let block = SwiftUI.Color(hex: "F5F3F0")
}
