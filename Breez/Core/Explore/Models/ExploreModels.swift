import Foundation

// MARK: - Resource Models
struct Resource: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let organization: String
    let type: ResourceType
    let category: ResourceCategory
    let imageUrl: String
    let location: String?
    let date: Date?
    var likes: Int
    var isLiked: Bool
    var isBookmarked: Bool
    let difficulty: DifficultyLevel
    let duration: String?
    let requirements: [String]
    let impact: EnvironmentalImpact?
    let contactInfo: ContactInfo?
    let website: String?
    
    enum ResourceType: String, CaseIterable, Codable {
        case event = "Event"
        case action = "Action"
        case education = "Education"
        case cleanup = "Cleanup"
        case workshop = "Workshop"
        case campaign = "Campaign"
        case volunteer = "Volunteer"
        case donation = "Donation"
    }
    
    enum ResourceCategory: String, CaseIterable, Codable {
        case ocean = "Ocean Conservation"
        case climate = "Climate Action"
        case waste = "Waste Reduction"
        case energy = "Energy Efficiency"
        case water = "Water Conservation"
        case biodiversity = "Biodiversity"
        case pollution = "Pollution Control"
        case sustainability = "Sustainability"
    }
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

// Expose nested enums at top-level for use across models
typealias ResourceType = Resource.ResourceType
typealias ResourceCategory = Resource.ResourceCategory
typealias DifficultyLevel = Resource.DifficultyLevel

struct ContactInfo: Codable {
    let email: String?
    let phone: String?
    let socialMedia: [String: String]?
}

// MARK: - Event Models
struct Event: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let organization: String
    let location: String
    let startDate: Date
    let endDate: Date?
    let imageUrl: String
    let maxParticipants: Int?
    let currentParticipants: Int
    let price: Double?
    let isFree: Bool
    let requirements: [String]
    let contactInfo: ContactInfo?
    let website: String?
    let isBookmarked: Bool
    let isRegistered: Bool
}

// MARK: - Action Models
struct Action: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let organization: String
    let type: ActionType
    let location: String?
    let imageUrl: String
    let startDate: Date?
    let endDate: Date?
    let isOngoing: Bool
    let participants: Int
    let goal: String?
    let progress: Double?
    let impact: EnvironmentalImpact?
    let requirements: [String]
    let contactInfo: ContactInfo?
    let website: String?
    let isBookmarked: Bool
    let isJoined: Bool
    
    enum ActionType: String, CaseIterable, Codable {
        case cleanup = "Cleanup"
        case restoration = "Restoration"
        case monitoring = "Monitoring"
        case advocacy = "Advocacy"
        case education = "Education"
        case research = "Research"
        case fundraising = "Fundraising"
    }
}

// MARK: - Education Models
struct EducationResource: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let organization: String
    let type: EducationType
    let category: ResourceCategory
    let imageUrl: String
    let duration: String?
    let difficulty: DifficultyLevel
    let language: String
    let isFree: Bool
    let price: Double?
    let rating: Double
    let reviews: Int
    let modules: [EducationModule]
    let requirements: [String]
    let certificate: Bool
    let contactInfo: ContactInfo?
    let website: String?
    let isBookmarked: Bool
    let isEnrolled: Bool
    
    enum EducationType: String, CaseIterable, Codable {
        case course = "Course"
        case workshop = "Workshop"
        case webinar = "Webinar"
        case tutorial = "Tutorial"
        case guide = "Guide"
        case article = "Article"
        case video = "Video"
        case podcast = "Podcast"
    }
}

struct EducationModule: Identifiable, Codable {
    let id = UUID()
    let title: String
    let description: String
    let duration: String?
    let isCompleted: Bool
    let order: Int
}

// MARK: - Search and Filter Models
struct SearchFilters: Codable {
    var categories: [ResourceCategory] = []
    var types: [ResourceType] = []
    var difficulty: [DifficultyLevel] = []
    var isFree: Bool?
    var location: String?
    var dateRange: DateRange?
    var sortBy: SortOption = .relevance
    
    enum SortOption: String, CaseIterable, Codable {
        case relevance = "Relevance"
        case date = "Date"
        case popularity = "Popularity"
        case rating = "Rating"
        case distance = "Distance"
    }
}

struct DateRange: Codable {
    let startDate: Date
    let endDate: Date
}

// MARK: - Bookmark Models
struct Bookmark: Identifiable, Codable {
    let id = UUID()
    let resourceId: UUID
    let resourceType: String
    let title: String
    let organization: String
    let imageUrl: String
    let dateAdded: Date
}

// MARK: - Wishlist Models
struct Wishlist: Identifiable, Codable {
    let id = UUID()
    let resourceId: UUID
    let resourceType: String
    let title: String
    let organization: String
    let imageUrl: String
    let dateAdded: Date
    let priority: Priority
    
    enum Priority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
}
