import UIKit
import CoreText

enum FontDebug {
    static func dumpCustomFonts() {
        let subdirs = [
            "Styles/Fonts",
            "Styles/Fonts/ProximaNova",
            "Styles/Fonts/Frijole"
        ]
        for subdir in subdirs {
            for ext in ["otf", "ttf"] {
                if let urls = Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: subdir) {
                    for url in urls {
                        var error: Unmanaged<CFError>?
                        CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error)
                    }
                }
            }
        }

        print("=== Installed Font Families ===")
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family).sorted()
            guard !names.isEmpty else { continue }
            print("Family: \(family)\n  Names: \(names)")
        }

        print("\n=== Candidate Names (Frijole / Proxima Nova) ===")
        let targets = ["frijole", "proxima"]
        for family in UIFont.familyNames {
            if targets.contains(where: { family.lowercased().contains($0) }) {
                let names = UIFont.fontNames(forFamilyName: family)
                for n in names { print("Family: \(family)  PS: \(n)") }
            }
        }
        print("=== End ===")
    }
}
