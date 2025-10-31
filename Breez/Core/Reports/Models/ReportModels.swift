import Foundation
import CoreLocation

// MARK: - Report Models
struct Report: Identifiable, Codable {
    let id = UUID()
    let userId: String
    let type: ReportType
    let category: ReportCategory
    let title: String
    let description: String
    let location: String
    let coordinates: CLLocationCoordinate2D?
    let imageUrls: [String]
    let evidence: String
    let status: ReportStatus
    let priority: ReportPriority
    let dateCreated: Date
    let dateUpdated: Date
    let analysis: ReportAnalysis?
    let tags: [String]
    let isPublic: Bool
    let isAnonymous: Bool
    let contactInfo: ContactInfo?
    let followUpRequired: Bool
    let followUpDate: Date?
    
    enum ReportType: String, CaseIterable, Codable {
        case pollution = "Pollution"
        case waste = "Waste"
        case oilSpill = "Oil Spill"
        case algaeBloom = "Algae Bloom"
        case erosion = "Erosion"
        case wildlife = "Wildlife"
        case illegalDumping = "Illegal Dumping"
        case waterQuality = "Water Quality"
        case noise = "Noise Pollution"
        case other = "Other"
    }
    
    enum ReportCategory: String, CaseIterable, Codable {
        case marine = "Marine"
        case coastal = "Coastal"
        case freshwater = "Freshwater"
        case air = "Air Quality"
        case land = "Land"
        case wildlife = "Wildlife"
        case noise = "Noise"
        case other = "Other"
    }
    
    enum ReportStatus: String, CaseIterable, Codable {
        case draft = "Draft"
        case pending = "Pending"
        case processing = "Processing"
        case ready = "Ready"
        case verified = "Verified"
        case rejected = "Rejected"
        case resolved = "Resolved"
        case error = "Error"
    }
    
    enum ReportPriority: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case urgent = "Urgent"
        case emergency = "Emergency"
    }
}

// MARK: - Report Analysis
struct ReportAnalysis: Codable {
    let pollutionType: String
    let severityLevel: SeverityLevel
    let ecosystemsAffected: [String]
    let marineImpact: String
    let confidence: Double
    let recommendations: [String]
    let estimatedCleanupCost: Double?
    let estimatedCleanupTime: String?
    let authoritiesNotified: [String]
    let nextSteps: [String]
    let relatedReports: [String]
    
    enum SeverityLevel: String, CaseIterable, Codable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        case critical = "Critical"
    }
}

// MARK: - Community Report
struct CommunityReport: Identifiable, Codable {
    let id = UUID()
    let type: String
    let location: String
    let description: String
    let imageUrl: String
    var likes: Int
    let date: Date
    let isAnonymized: Bool
    let author: String?
    let comments: [Comment]
    var isLiked: Bool
    var isBookmarked: Bool
    let tags: [String]
    let status: CommunityReportStatus
    
    enum CommunityReportStatus: String, CaseIterable, Codable {
        case pending = "Pending"
        case verified = "Verified"
        case disputed = "Disputed"
        case resolved = "Resolved"
    }
}

// MARK: - Comment
struct Comment: Identifiable, Codable {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: Date
    let isAuthor: Bool
    let likes: Int
    let isLiked: Bool
    let replies: [Comment]
}

// MARK: - Report Statistics
struct ReportStatistics: Codable {
    let totalReports: Int
    let reportsThisMonth: Int
    let reportsThisWeek: Int
    let reportsToday: Int
    let verifiedReports: Int
    let pendingReports: Int
    let resolvedReports: Int
    let reportsByType: [String: Int]
    let reportsByCategory: [String: Int]
    let reportsByStatus: [String: Int]
    let averageProcessingTime: TimeInterval
    let mostCommonLocation: String?
    let mostCommonType: String?
}

// MARK: - Report Filter
struct ReportFilter: Codable {
    var types: [Report.ReportType] = []
    var categories: [Report.ReportCategory] = []
    var statuses: [Report.ReportStatus] = []
    var priorities: [Report.ReportPriority] = []
    var dateRange: DateRange?
    var location: String?
    var isPublic: Bool?
    var sortBy: SortOption = .dateCreated
    
    enum SortOption: String, CaseIterable, Codable {
        case dateCreated = "Date Created"
        case dateUpdated = "Date Updated"
        case priority = "Priority"
        case status = "Status"
        case type = "Type"
        case location = "Location"
    }
}

// MARK: - Report Template
struct ReportTemplate: Identifiable, Codable {
    let id = UUID()
    let name: String
    let description: String
    let type: Report.ReportType
    let category: Report.ReportCategory
    let requiredFields: [ReportField]
    let optionalFields: [ReportField]
    let guidelines: [String]
    let examples: [String]
    let isActive: Bool
}

// MARK: - Report Field
struct ReportField: Identifiable, Codable {
    let id = UUID()
    let name: String
    let type: FieldType
    let isRequired: Bool
    let placeholder: String?
    let options: [String]?
    let validation: ValidationRule?
    
    enum FieldType: String, CaseIterable, Codable {
        case text = "Text"
        case textArea = "Text Area"
        case number = "Number"
        case date = "Date"
        case time = "Time"
        case location = "Location"
        case image = "Image"
        case multipleChoice = "Multiple Choice"
        case singleChoice = "Single Choice"
        case boolean = "Yes/No"
        case rating = "Rating"
    }
}

// MARK: - Validation Rule
struct ValidationRule: Codable {
    let minLength: Int?
    let maxLength: Int?
    let minValue: Double?
    let maxValue: Double?
    let pattern: String?
    let customMessage: String?
}

// MARK: - Report Submission
struct ReportSubmission {
    let templateId: UUID
    let fields: [String: String]
    let images: [Data]
    let location: CLLocationCoordinate2D?
    let isPublic: Bool
    let isAnonymous: Bool
    let contactInfo: ContactInfo?
}

// MARK: - Report Notification
struct ReportNotification: Identifiable, Codable {
    let id = UUID()
    let reportId: UUID
    let type: NotificationType
    let title: String
    let message: String
    let timestamp: Date
    let isRead: Bool
    let actionUrl: String?
    
    enum NotificationType: String, CaseIterable, Codable {
        case statusUpdate = "Status Update"
        case analysisComplete = "Analysis Complete"
        case verificationRequired = "Verification Required"
        case resolutionUpdate = "Resolution Update"
        case followUpRequired = "Follow-up Required"
        case communityResponse = "Community Response"
    }
}

// MARK: - CLLocationCoordinate2D Codable Extension
extension CLLocationCoordinate2D: Codable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: latitude, longitude: longitude)
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, longitude
    }
}
