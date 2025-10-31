import Foundation

struct User: Codable {
    let id: String
    let referralCode: String
    let referredBy: String?
    let referralCount: Int
    let freeReports: Int
    let isSubscribed: Bool
    let createdAt: Date
    let updatedAt: Date
    let profile: UserProfile
    
    init(
        id: String,
        referralCode: String = generateReferralCode(),
        referredBy: String? = nil,
        referralCount: Int = 0,
        freeReports: Int = 0,
        isSubscribed: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        profile: UserProfile = UserProfile()
    ) {
        self.id = id
        self.referralCode = referralCode
        self.referredBy = referredBy
        self.referralCount = referralCount
        self.freeReports = freeReports
        self.isSubscribed = isSubscribed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.profile = profile
    }
    
    private static func generateReferralCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<8).map { _ in letters.randomElement()! })
    }
}

struct UserProfile: Codable {
    let location: String?
    let interests: [String]
    let age: String?
    let name: String?
    let concerns: [String]
    let budget: Int?
    let actionPreferences: [String]
    let environmentalGoals: [String]
    let coastalConcerns: [String]
    let timePerWeek: Double?
    let budgetPerMonth: Double?
    let likedResources: [String]
    let hasCompletedOnboarding: Bool
    
    init(
        location: String? = nil,
        interests: [String] = [],
        age: String? = nil,
        name: String? = nil,
        concerns: [String] = [],
        budget: Int? = nil,
        actionPreferences: [String] = [],
        environmentalGoals: [String] = [],
        coastalConcerns: [String] = [],
        timePerWeek: Double? = nil,
        budgetPerMonth: Double? = nil,
        likedResources: [String] = [],
        hasCompletedOnboarding: Bool = false
    ) {
        self.location = location
        self.interests = interests
        self.age = age
        self.name = name
        self.concerns = concerns
        self.budget = budget
        self.actionPreferences = actionPreferences
        self.environmentalGoals = environmentalGoals
        self.coastalConcerns = coastalConcerns
        self.timePerWeek = timePerWeek
        self.budgetPerMonth = budgetPerMonth
        self.likedResources = likedResources
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }
}
