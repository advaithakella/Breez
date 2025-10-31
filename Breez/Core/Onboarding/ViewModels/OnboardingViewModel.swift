import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var environmentalGoals: [String] = []
    @Published var location: String = ""
    @Published var coastalConcerns: [String] = []
    @Published var interests: [String] = []
    @Published var concerns: [String] = []
    @Published var timePerWeek: Double = 0
    @Published var budgetPerMonth: Double = 0
    @Published var likedResources: [String] = []
    @Published var name: String = ""
    @Published var ageRange: String = ""
    @Published var rating: Int = 0
    
    func updateEnvironmentalGoals(_ goals: [String]) {
        environmentalGoals = goals
    }
    
    func updateLocation(_ location: String) {
        self.location = location
    }
    
    func updateCoastalConcerns(_ concerns: [String]) {
        coastalConcerns = concerns
    }
    
    func updateInterests(_ interests: [String]) {
        self.interests = interests
    }
    
    func updateConcerns(_ concerns: [String]) {
        self.concerns = concerns
    }
    
    func updateTimePerWeek(_ time: Double) {
        timePerWeek = time
    }
    
    func updateBudgetPerMonth(_ budget: Double) {
        budgetPerMonth = budget
    }
    
    func updateLikedResources(_ resources: [String]) {
        likedResources = resources
    }
    
    func updateName(_ name: String) {
        self.name = name
    }
    
    func updateAgeRange(_ ageRange: String) {
        self.ageRange = ageRange
    }
    
    func updateRating(_ rating: Int) {
        self.rating = rating
    }
    
    func skipRating() {
        rating = 0
    }
    
    func completeOnboarding() {
        // This will be called when onboarding is complete
        // The actual completion logic is handled in the OnboardingView
    }
}
