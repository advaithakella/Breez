import SwiftUI
import CoreText
import UIKit

extension Font {
    // MARK: - Frijole (display)
    static func frijole(size: CGFloat) -> Font {
        .custom("Frijole", size: size)
    }

    // MARK: - Proxima Nova (Semibold)
    static func proximaNovaSemibold(size: CGFloat) -> Font {
        .custom("ProximaNova-Semibold", size: size)
    }
    // MARK: - Instrument Sans
    static func instrumentSans(_ weight: Font.Weight = .medium, size: CGFloat) -> Font {
        let fontName = "InstrumentSans-\(weight.fontName)"
        return .custom(fontName, size: size)
    }
    
    // MARK: - Söhne (SohneBreit-Dreiviertelfett)
    static func sohne(_ weight: Font.Weight = .bold, size: CGFloat) -> Font {
        // Use the correct PostScript font name from FontBook
        let name: String
        switch weight {
        case .bold:
            name = "SohneBreit-Dreiviertelfett"
        case .medium:
            name = "SohneBreit-Dreiviertelfett" // fallback; add more files if needed
        default:
            name = "SohneBreit-Dreiviertelfett"
        }
        return .custom(name, size: size)
    }
}

extension Font.Weight {
    var fontName: String {
        switch self {
        case .medium: return "Medium"
        case .bold: return "Bold"
        default: return "Medium"
        }
    }
}

// MARK: - Runtime font registration (no Info.plist needed)
enum FontRegistrar {
    static func registerAllCustomFonts() {
        // Register fonts from known subdirectories
        let roots = [
            "Styles/Fonts",
            "Styles/Fonts/Frijole",
            "Styles/Fonts/ProximaNova"
        ]
        var urls: [URL] = []
        for dir in roots {
            urls += Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: dir) ?? []
            urls += Bundle.main.urls(forResourcesWithExtension: "ttf", subdirectory: dir) ?? []
        }
        let assetFonts = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: "Styles/Assets.xcassets/CustomFonts.fontset") ?? []
        for url in urls + assetFonts {
            var error: Unmanaged<CFError>?
            let ok = CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
            #if DEBUG
            if !ok, let e = error?.takeRetainedValue() {
                print("[FontRegistrar] Failed to register", url.lastPathComponent, e)
            } else {
                print("[FontRegistrar] Registered font:", url.lastPathComponent)
            }
            #endif
        }
    }
}

// MARK: - UIFont Extension for UIKit Components
extension UIFont {
    // MARK: - Frijole
    static func frijole(size: CGFloat) -> UIFont {
        if let font = UIFont(name: "Frijole", size: size) { return font }
        return UIFont.systemFont(ofSize: size, weight: .bold)
    }

    // MARK: - Proxima Nova Semibold
    static func proximaNovaSemibold(size: CGFloat) -> UIFont {
        if let font = UIFont(name: "ProximaNova-Semibold", size: size) { return font }
        return UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    // MARK: - Söhne (SohneBreit-Dreiviertelfett) for UIKit
    static func sohne(_ weight: UIFont.Weight = .bold, size: CGFloat) -> UIFont {
        // Use the correct PostScript font name from FontBook
        let name: String
        switch weight {
        case .bold:
            name = "SohneBreit-Dreiviertelfett"
        case .medium:
            name = "SohneBreit-Dreiviertelfett" // fallback; add more files if needed
        default:
            name = "SohneBreit-Dreiviertelfett"
        }
        
        if let font = UIFont(name: name, size: size) {
            return font
        }
        // Fallback safely to system font if custom font is not yet available
        return UIFont.systemFont(ofSize: size, weight: weight)
    }
}
