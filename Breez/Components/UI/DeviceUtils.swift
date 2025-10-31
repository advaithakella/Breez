import SwiftUI
import UIKit

struct DeviceUtils {
    // MARK: - Screen Dimensions
    static var screenWidth: CGFloat {
        UIScreen.main.bounds.width
    }
    
    static var screenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    // MARK: - Screen Size Categories
    static var isCompactScreen: Bool {
        let width = screenWidth
        let height = screenHeight
        return width <= 375 || height <= 667
    }
    
    static var isStandardScreen: Bool {
        let width = screenWidth
        let height = screenHeight
        return (width > 375 && width <= 428) || (height > 667 && height <= 926)
    }
    
    static var isLargeScreen: Bool {
        let width = screenWidth
        let height = screenHeight
        return width > 428 || height > 926
    }
    
    // MARK: - Device Type (for reference)
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    // MARK: - Layout Decisions
    static var shouldUseCompactLayout: Bool {
        isCompactScreen
    }
    
    static var shouldUseStandardLayout: Bool {
        isStandardScreen
    }
    
    static var shouldUseLargeLayout: Bool {
        isLargeScreen
    }
    
    // MARK: - Spacing Adjustments
    static var compactSpacing: CGFloat { 8 }
    static var standardSpacing: CGFloat { 12 }
    static var largeSpacing: CGFloat { 16 }
    
    static var compactPadding: CGFloat { 16 }
    static var standardPadding: CGFloat { 20 }
    static var largePadding: CGFloat { 24 }
    
    // MARK: - Font Size Adjustments
    static var compactFontSize: CGFloat { 16 }
    static var standardFontSize: CGFloat { 18 }
    static var largeFontSize: CGFloat { 22 }
    
    // MARK: - Debug Info
    static func logScreenInfo() {
        // Screen info logging removed
    }
}