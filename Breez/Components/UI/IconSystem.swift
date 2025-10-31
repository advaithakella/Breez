import SwiftUI

// Phosphor-style icon system using SF Symbols as fallback
struct Ph {
    // Navigation & UI
    static let gear = "gearshape.fill"
    static let caretDown = "chevron.down"
    static let caretRight = "chevron.right"
    static let caretLeft = "chevron.left"
    static let caretUp = "chevron.up"
    static let magnifyingGlass = "magnifyingglass"
    static let x = "xmark"
    static let plus = "plus"
    static let minus = "minus"
    static let check = "checkmark"
    static let xmark = "xmark"
    
    // Environmental & Nature
    static let leaf = "leaf.fill"
    static let tree = "tree.fill"
    static let sun = "sun.max.fill"
    static let moon = "moon.fill"
    static let cloud = "cloud.fill"
    static let cloudRain = "cloud.rain.fill"
    static let wind = "wind"
    static let drop = "drop.fill"
    static let flame = "flame.fill"
    static let mountain = "mountain.2.fill"
    static let waves = "wave.3.right"
    static let recycle = "arrow.triangle.2.circlepath"
    static let globe = "globe"
    static let location = "location.fill"
    
    // Activities & Actions
    static let walk = "figure.walk"
    static let bike = "bicycle"
    static let car = "car.fill"
    static let bus = "bus.fill"
    static let train = "tram.fill"
    static let trash = "trash.fill"
    static let recycleBin = "trash.circle.fill"
    static let lightbulb = "lightbulb.fill"
    static let battery = "battery.100"
    static let plug = "powerplug.fill"
    
    // Social & Community
    static let heart = "heart.fill"
    static let heartOutline = "heart"
    static let user = "person.fill"
    static let users = "person.2.fill"
    static let chat = "bubble.left.fill"
    static let share = "square.and.arrow.up"
    static let bookmark = "bookmark.fill"
    static let bookmarkOutline = "bookmark"
    static let star = "star.fill"
    static let starOutline = "star"
    
    // Media & Content
    static let camera = "camera.fill"
    static let photo = "photo.fill"
    static let video = "video.fill"
    static let mic = "mic.fill"
    static let play = "play.fill"
    static let pause = "pause.fill"
    static let stop = "stop.fill"
    static let forward = "forward.fill"
    static let backward = "backward.fill"
    
    // Data & Reports
    static let chart = "chart.bar.fill"
    static let chartLine = "chart.line.uptrend.xyaxis"
    static let doc = "doc.fill"
    static let docText = "doc.text.fill"
    static let list = "list.bullet"
    static let grid = "grid"
    static let calendar = "calendar"
    static let clock = "clock.fill"
    static let timer = "timer"
    
    // Status & Progress
    static let checkCircle = "checkmark.circle.fill"
    static let xCircle = "xmark.circle.fill"
    static let exclamation = "exclamationmark.triangle.fill"
    static let info = "info.circle.fill"
    static let warning = "exclamationmark.triangle.fill"
    static let success = "checkmark.circle.fill"
    static let error = "xmark.circle.fill"
    
    // Navigation Tabs
    static let home = "house.fill"
    static let explore = "safari.fill"
    static let reports = "doc.text.fill"
    static let progress = "chart.line.uptrend.xyaxis"
    static let profile = "person.circle.fill"
    
    // Legacy (keeping for compatibility)
    static let fire = "flame.fill"
    static let googlePodcastsLogo = "wave.3.right"
    static let hexagon = "hexagon.fill"
}

extension String {
    func bold() -> String { return self }
    func color(_ color: Color) -> some View {
        Image(systemName: self)
            .foregroundColor(color)
    }
}
