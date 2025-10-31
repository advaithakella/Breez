import Foundation

class HomeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var recentActivities: [Activity] = []
    @Published var activities: [Activity] = []
    @Published var activeChallenges: [Challenge] = []
    @Published var availableChallenges: [Challenge] = []
    @Published var communityPosts: [CommunityPost] = []
    @Published var userStats: UserStats?
    @Published var communityStats: CommunityStats?
    @Published var isLoading = false
    
    // MARK: - Initialization
    init() {
        loadData()
    }
    
    // MARK: - Public Methods
    func loadData() {
        isLoading = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.loadMockData()
            self.isLoading = false
        }
    }
    
    func refreshData() {
        loadData()
    }
    
    func joinChallenge(_ challenge: Challenge) {
        // Handle joining a challenge
        if let index = availableChallenges.firstIndex(where: { $0.id == challenge.id }) {
            var updatedChallenge = challenge
            updatedChallenge.isActive = true
            updatedChallenge.startDate = Date()
            updatedChallenge.endDate = Calendar.current.date(byAdding: .day, value: challenge.duration, to: Date())
            
            availableChallenges.remove(at: index)
            activeChallenges.append(updatedChallenge)
        }
    }
    
    func completeActivity(_ activity: Activity) {
        // Handle completing an activity
        if let index = activities.firstIndex(where: { $0.id == activity.id }) {
            var updatedActivity = activity
            updatedActivity.isCompleted = true
            activities[index] = updatedActivity
            recentActivities.insert(updatedActivity, at: 0)
        }
    }
    
    func likePost(_ post: CommunityPost) {
        // Handle liking a post
        if let index = communityPosts.firstIndex(where: { $0.id == post.id }) {
            var updatedPost = post
            updatedPost.isLiked.toggle()
            updatedPost.likes += updatedPost.isLiked ? 1 : -1
            communityPosts[index] = updatedPost
        }
    }
    
    // MARK: - Private Methods
    private func loadMockData() {
        loadRecentActivities()
        loadActivities()
        loadChallenges()
        loadCommunityPosts()
        loadUserStats()
        loadCommunityStats()
    }
    
    private func loadRecentActivities() {
        recentActivities = [
            Activity(
                title: "Used reusable water bottle",
                description: "Avoided single-use plastic bottle",
                category: .waste,
                impact: EnvironmentalImpact(carbonSaved: 0.1, plasticAvoided: 1, waterSaved: 0, energySaved: 0),
                timestamp: Date().addingTimeInterval(-3600),
                isCompleted: true
            ),
            Activity(
                title: "Walked to work",
                description: "Instead of driving, walked 2 miles to work",
                category: .transportation,
                impact: EnvironmentalImpact(carbonSaved: 0.8, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                timestamp: Date().addingTimeInterval(-7200),
                isCompleted: true
            ),
            Activity(
                title: "Turned off lights",
                description: "Switched off all unnecessary lights",
                category: .energy,
                impact: EnvironmentalImpact(carbonSaved: 0.2, plasticAvoided: 0, waterSaved: 0, energySaved: 1.5),
                timestamp: Date().addingTimeInterval(-10800),
                isCompleted: true
            )
        ]
    }
    
    private func loadActivities() {
        activities = [
            Activity(
                title: "Recycle plastic containers",
                description: "Sort and recycle all plastic containers from this week",
                category: .waste,
                impact: EnvironmentalImpact(carbonSaved: 0.3, plasticAvoided: 5, waterSaved: 0, energySaved: 0),
                timestamp: Date(),
                isCompleted: false
            ),
            Activity(
                title: "Use public transport",
                description: "Take the bus instead of driving to the mall",
                category: .transportation,
                impact: EnvironmentalImpact(carbonSaved: 1.2, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                timestamp: Date(),
                isCompleted: false
            ),
            Activity(
                title: "Fix leaky faucet",
                description: "Repair the dripping kitchen faucet to save water",
                category: .water,
                impact: EnvironmentalImpact(carbonSaved: 0.1, plasticAvoided: 0, waterSaved: 20, energySaved: 0),
                timestamp: Date(),
                isCompleted: false
            ),
            Activity(
                title: "Buy local produce",
                description: "Purchase fruits and vegetables from local farmers market",
                category: .food,
                impact: EnvironmentalImpact(carbonSaved: 0.5, plasticAvoided: 3, waterSaved: 0, energySaved: 0),
                timestamp: Date(),
                isCompleted: false
            )
        ]
    }
    
    private func loadChallenges() {
        activeChallenges = [
            Challenge(
                title: "7-Day Plastic-Free Challenge",
                description: "Avoid all single-use plastics for one week",
                category: .daily,
                duration: 7,
                difficulty: .medium,
                reward: "Eco Warrior Badge",
                requirements: ["No plastic bags", "No plastic bottles", "No plastic straws"],
                isActive: true,
                isCompleted: false,
                progress: 0.6,
                startDate: Date().addingTimeInterval(-172800),
                endDate: Date().addingTimeInterval(432000)
            )
        ]
        
        availableChallenges = [
            Challenge(
                title: "30-Day Carbon Footprint Challenge",
                description: "Reduce your carbon footprint by 20% this month",
                category: .monthly,
                duration: 30,
                difficulty: .hard,
                reward: "Climate Champion Badge",
                requirements: ["Walk or bike to work", "Use energy-efficient appliances", "Eat plant-based meals"],
                isActive: false,
                isCompleted: false,
                progress: 0.0,
                startDate: nil,
                endDate: nil
            ),
            Challenge(
                title: "Water Conservation Week",
                description: "Save 100 gallons of water this week",
                category: .weekly,
                duration: 7,
                difficulty: .easy,
                reward: "Water Saver Badge",
                requirements: ["Take shorter showers", "Fix leaks", "Use rain barrel"],
                isActive: false,
                isCompleted: false,
                progress: 0.0,
                startDate: nil,
                endDate: nil
            ),
            Challenge(
                title: "Zero Waste Weekend",
                description: "Produce no waste for an entire weekend",
                category: .weekly,
                duration: 2,
                difficulty: .expert,
                reward: "Zero Waste Master Badge",
                requirements: ["No trash produced", "Compost all food waste", "Use only reusable items"],
                isActive: false,
                isCompleted: false,
                progress: 0.0,
                startDate: nil,
                endDate: nil
            )
        ]
    }
    
    private func loadCommunityPosts() {
        communityPosts = [
            CommunityPost(
                author: "EcoWarrior123",
                authorAvatar: nil,
                content: "Just completed my first beach cleanup! Found 47 pieces of plastic debris. Every little bit helps! 🌊♻️",
                imageURL: nil,
                timestamp: Date().addingTimeInterval(-1800),
                likes: 24,
                comments: 8,
                shares: 3,
                isLiked: false
            ),
            CommunityPost(
                author: "GreenThumb",
                authorAvatar: nil,
                content: "Started my own vegetable garden to reduce food miles. Growing tomatoes, lettuce, and herbs! 🍅🥬",
                imageURL: nil,
                timestamp: Date().addingTimeInterval(-3600),
                likes: 18,
                comments: 12,
                shares: 5,
                isLiked: true
            ),
            CommunityPost(
                author: "BikeCommuter",
                authorAvatar: nil,
                content: "Day 15 of biking to work! Saved 15kg of CO2 and got some great exercise. Who else is biking this week? 🚴‍♂️",
                imageURL: nil,
                timestamp: Date().addingTimeInterval(-7200),
                likes: 31,
                comments: 15,
                shares: 7,
                isLiked: false
            )
        ]
    }
    
    private func loadUserStats() {
        userStats = UserStats(
            carbonSaved: 2.4,
            plasticAvoided: 12,
            waterSaved: 45.0,
            currentStreak: 7,
            totalActivities: 23,
            challengesCompleted: 3,
            rank: 156,
            level: 5,
            xp: 1250
        )
    }
    
    private func loadCommunityStats() {
        communityStats = CommunityStats(
            totalMembers: 1234,
            totalCO2Saved: 2.4,
            totalPlasticAvoided: 5678,
            totalWaterSaved: 12345.0
        )
    }
}
