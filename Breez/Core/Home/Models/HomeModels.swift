import Foundation

// MARK: - Activity Models
struct Activity: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: ActivityCategory
    let impact: EnvironmentalImpact
    let timestamp: Date
    var isCompleted: Bool
    
    enum ActivityCategory: String, CaseIterable, Codable {
        case transportation = "Transportation"
        case energy = "Energy"
        case waste = "Waste"
        case water = "Water"
        case food = "Food"
        case lifestyle = "Lifestyle"
    }
}

struct EnvironmentalImpact: Codable {
    let carbonSaved: Double // in kg
    let plasticAvoided: Int // in items
    let waterSaved: Double // in liters
    let energySaved: Double // in kWh
}

// MARK: - Challenge Models
struct Challenge: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let category: ChallengeCategory
    let duration: Int // in days
    let difficulty: ChallengeDifficulty
    let reward: String
    let requirements: [String]
    var isActive: Bool
    var isCompleted: Bool
    var progress: Double // 0.0 to 1.0
    var startDate: Date?
    var endDate: Date?
    
    enum ChallengeCategory: String, CaseIterable, Codable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
        case seasonal = "Seasonal"
    }
    
    enum ChallengeDifficulty: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
    }
}

// MARK: - Community Models
struct CommunityPost: Identifiable, Codable {
    let id = UUID()
    let author: String
    let authorAvatar: String?
    let content: String
    let imageURL: String?
    let timestamp: Date
    var likes: Int
    let comments: Int
    let shares: Int
    var isLiked: Bool
}

struct CommunityStats: Codable {
    let totalMembers: Int
    let totalCO2Saved: Double // in tons
    let totalPlasticAvoided: Int
    let totalWaterSaved: Double // in liters
}

// MARK: - User Stats Models
struct UserStats: Codable {
    let carbonSaved: Double
    let plasticAvoided: Int
    let waterSaved: Double
    let currentStreak: Int
    let totalActivities: Int
    let challengesCompleted: Int
    let rank: Int
    let level: Int
    let xp: Int
}

// MARK: - Quick Action Models
struct QuickAction: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let color: String
    let action: () -> Void
}
