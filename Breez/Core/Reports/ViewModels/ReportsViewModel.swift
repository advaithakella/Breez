import Foundation
import CoreLocation

class ReportsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var reports: [Report] = []
    @Published var filteredReports: [Report] = []
    @Published var communityReports: [CommunityReport] = []
    @Published var statistics: ReportStatistics?
    @Published var templates: [ReportTemplate] = []
    @Published var notifications: [ReportNotification] = []
    @Published var currentFilter = ReportFilter()
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
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
    
    func refreshReports() {
        loadData()
    }
    
    func searchReports(query: String) {
        searchText = query
        
        if query.isEmpty {
            filteredReports = reports
        } else {
            filteredReports = reports.filter { report in
                report.title.localizedCaseInsensitiveContains(query) ||
                report.description.localizedCaseInsensitiveContains(query) ||
                report.location.localizedCaseInsensitiveContains(query) ||
                report.type.rawValue.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func applyFilters(_ filter: ReportFilter) {
        currentFilter = filter
        
        var filtered = reports
        
        // Apply type filter
        if !filter.types.isEmpty {
            filtered = filtered.filter { filter.types.contains($0.type) }
        }
        
        // Apply category filter
        if !filter.categories.isEmpty {
            filtered = filtered.filter { filter.categories.contains($0.category) }
        }
        
        // Apply status filter
        if !filter.statuses.isEmpty {
            filtered = filtered.filter { filter.statuses.contains($0.status) }
        }
        
        // Apply priority filter
        if !filter.priorities.isEmpty {
            filtered = filtered.filter { filter.priorities.contains($0.priority) }
        }
        
        // Apply date range filter
        if let dateRange = filter.dateRange {
            filtered = filtered.filter { report in
                report.dateCreated >= dateRange.startDate && report.dateCreated <= dateRange.endDate
            }
        }
        
        // Apply location filter
        if let location = filter.location, !location.isEmpty {
            filtered = filtered.filter { $0.location.localizedCaseInsensitiveContains(location) }
        }
        
        // Apply public filter
        if let isPublic = filter.isPublic {
            filtered = filtered.filter { $0.isPublic == isPublic }
        }
        
        // Apply sorting
        switch filter.sortBy {
        case .dateCreated:
            filtered = filtered.sorted { $0.dateCreated > $1.dateCreated }
        case .dateUpdated:
            filtered = filtered.sorted { $0.dateUpdated > $1.dateUpdated }
        case .priority:
            let priorityOrder: [Report.ReportPriority] = [.emergency, .urgent, .high, .medium, .low]
            filtered = filtered.sorted { priorityOrder.firstIndex(of: $0.priority) ?? 5 < priorityOrder.firstIndex(of: $1.priority) ?? 5 }
        case .status:
            filtered = filtered.sorted { $0.status.rawValue < $1.status.rawValue }
        case .type:
            filtered = filtered.sorted { $0.type.rawValue < $1.type.rawValue }
        case .location:
            filtered = filtered.sorted { $0.location < $1.location }
        }
        
        filteredReports = filtered
    }
    
    func createReport(_ submission: ReportSubmission) {
        // Handle report creation
        let newReport = Report(
            userId: "current_user", // Would get from auth
            type: .pollution, // Would determine from template
            category: .marine,
            title: "New Report",
            description: "Report description",
            location: "Location",
            coordinates: submission.location,
            imageUrls: [], // Would process images
            evidence: "Evidence",
            status: .draft,
            priority: .medium,
            dateCreated: Date(),
            dateUpdated: Date(),
            analysis: nil,
            tags: [],
            isPublic: submission.isPublic,
            isAnonymous: submission.isAnonymous,
            contactInfo: submission.contactInfo,
            followUpRequired: false,
            followUpDate: nil
        )
        
        reports.insert(newReport, at: 0)
        updateFilteredReports()
    }
    
    func updateReport(_ report: Report) {
        if let index = reports.firstIndex(where: { $0.id == report.id }) {
            reports[index] = report
            updateFilteredReports()
        }
    }
    
    func deleteReport(_ reportId: UUID) {
        reports.removeAll { $0.id == reportId }
        updateFilteredReports()
    }
    
    func likeCommunityReport(_ report: CommunityReport) {
        if let index = communityReports.firstIndex(where: { $0.id == report.id }) {
            var updatedReport = report
            updatedReport.isLiked.toggle()
            updatedReport.likes += updatedReport.isLiked ? 1 : -1
            communityReports[index] = updatedReport
        }
    }
    
    func bookmarkCommunityReport(_ report: CommunityReport) {
        if let index = communityReports.firstIndex(where: { $0.id == report.id }) {
            var updatedReport = report
            updatedReport.isBookmarked.toggle()
            communityReports[index] = updatedReport
        }
    }
    
    // MARK: - Private Methods
    private func loadMockData() {
        loadReports()
        loadCommunityReports()
        loadStatistics()
        loadTemplates()
        loadNotifications()
        applyFilters(currentFilter)
    }
    
    private func loadReports() {
        reports = [
            Report(
                userId: "user1",
                type: .waste,
                category: .marine,
                title: "Plastic Debris on Beach",
                description: "Large amount of plastic debris washed up on Santa Monica Beach after recent storm",
                location: "Santa Monica Beach, CA",
                coordinates: CLLocationCoordinate2D(latitude: 34.0195, longitude: -118.4912),
                imageUrls: ["https://example.com/image1.jpg"],
                evidence: "Plastic bottles, bags, and microplastics scattered across 200m of beach",
                status: .verified,
                priority: .high,
                dateCreated: Date().addingTimeInterval(-86400 * 2),
                dateUpdated: Date().addingTimeInterval(-3600),
                analysis: ReportAnalysis(
                    pollutionType: "Plastic Waste",
                    severityLevel: .high,
                    ecosystemsAffected: ["Marine", "Beach", "Coastal"],
                    marineImpact: "Threat to marine life, birds, and beach ecosystem",
                    confidence: 0.85,
                    recommendations: [
                        "Organize immediate beach cleanup",
                        "Contact Surfrider Foundation",
                        "Report to city environmental department"
                    ],
                    estimatedCleanupCost: 2500.0,
                    estimatedCleanupTime: "4-6 hours",
                    authoritiesNotified: ["City of Santa Monica", "Heal the Bay"],
                    nextSteps: [
                        "Schedule cleanup event",
                        "Coordinate with local groups",
                        "Document cleanup progress"
                    ],
                    relatedReports: []
                ),
                tags: ["plastic", "beach", "storm", "marine-life"],
                isPublic: true,
                isAnonymous: false,
                contactInfo: ContactInfo(email: "reporter@example.com", phone: nil, socialMedia: nil),
                followUpRequired: true,
                followUpDate: Date().addingTimeInterval(86400 * 7)
            ),
            Report(
                userId: "user1",
                type: .oilSpill,
                category: .marine,
                title: "Oil Slick Observed",
                description: "Oil slick observed on water surface near Venice Pier",
                location: "Venice Beach, CA",
                coordinates: CLLocationCoordinate2D(latitude: 33.9850, longitude: -118.4695),
                imageUrls: ["https://example.com/image2.jpg"],
                evidence: "Rainbow sheen on water surface, strong petroleum odor",
                status: .processing,
                priority: .urgent,
                dateCreated: Date().addingTimeInterval(-3600 * 6),
                dateUpdated: Date().addingTimeInterval(-1800),
                analysis: nil,
                tags: ["oil", "spill", "venice", "water"],
                isPublic: true,
                isAnonymous: false,
                contactInfo: ContactInfo(email: "reporter@example.com", phone: nil, socialMedia: nil),
                followUpRequired: true,
                followUpDate: Date().addingTimeInterval(86400 * 3)
            ),
            Report(
                userId: "user1",
                type: .algaeBloom,
                category: .marine,
                title: "Red Tide at Malibu",
                description: "Red tide observed along Malibu coastline",
                location: "Malibu Beach, CA",
                coordinates: CLLocationCoordinate2D(latitude: 34.0259, longitude: -118.7798),
                imageUrls: ["https://example.com/image3.jpg"],
                evidence: "Reddish-brown discoloration of water, dead fish on shore",
                status: .ready,
                priority: .medium,
                dateCreated: Date().addingTimeInterval(-86400 * 5),
                dateUpdated: Date().addingTimeInterval(-3600 * 12),
                analysis: ReportAnalysis(
                    pollutionType: "Harmful Algal Bloom",
                    severityLevel: .medium,
                    ecosystemsAffected: ["Marine", "Coastal"],
                    marineImpact: "Reduced oxygen levels affecting fish and marine life",
                    confidence: 0.92,
                    recommendations: [
                        "Avoid swimming in affected area",
                        "Report to health department",
                        "Monitor water quality regularly"
                    ],
                    estimatedCleanupCost: nil,
                    estimatedCleanupTime: "Natural dissipation expected in 1-2 weeks",
                    authoritiesNotified: ["LA County Health Department", "California Water Board"],
                    nextSteps: [
                        "Continue monitoring",
                        "Update beach advisories",
                        "Collect water samples"
                    ],
                    relatedReports: []
                ),
                tags: ["red-tide", "algae", "malibu", "water-quality"],
                isPublic: true,
                isAnonymous: false,
                contactInfo: ContactInfo(email: "reporter@example.com", phone: nil, socialMedia: nil),
                followUpRequired: false,
                followUpDate: nil
            )
        ]
    }
    
    private func loadCommunityReports() {
        communityReports = [
            CommunityReport(
                type: "Marine Debris",
                location: "Huntington Beach",
                description: "Plastic bottles and fishing gear washed ashore after storm",
                imageUrl: "https://example.com/community1.jpg",
                likes: 24,
                date: Date().addingTimeInterval(-3600),
                isAnonymized: true,
                author: "EcoWarrior123",
                comments: [],
                isLiked: false,
                isBookmarked: false,
                tags: ["plastic", "storm", "huntington"],
                status: .verified
            ),
            CommunityReport(
                type: "Beach Erosion",
                location: "Pacifica Beach",
                description: "Significant erosion observed after high tide",
                imageUrl: "https://example.com/community2.jpg",
                likes: 18,
                date: Date().addingTimeInterval(-7200),
                isAnonymized: true,
                author: "CoastWatcher",
                comments: [],
                isLiked: true,
                isBookmarked: false,
                tags: ["erosion", "tide", "coastal"],
                status: .pending
            )
        ]
    }
    
    private func loadStatistics() {
        statistics = ReportStatistics(
            totalReports: 47,
            reportsThisMonth: 12,
            reportsThisWeek: 3,
            reportsToday: 1,
            verifiedReports: 35,
            pendingReports: 8,
            resolvedReports: 4,
            reportsByType: [
                "Waste": 15,
                "Pollution": 12,
                "Oil Spill": 3,
                "Algae Bloom": 8,
                "Erosion": 5,
                "Wildlife": 4
            ],
            reportsByCategory: [
                "Marine": 28,
                "Coastal": 12,
                "Freshwater": 4,
                "Air Quality": 3
            ],
            reportsByStatus: [
                "Verified": 35,
                "Pending": 8,
                "Processing": 2,
                "Resolved": 2
            ],
            averageProcessingTime: 86400 * 2, // 2 days
            mostCommonLocation: "Santa Monica Beach",
            mostCommonType: "Waste"
        )
    }
    
    private func loadTemplates() {
        templates = [
            ReportTemplate(
                name: "Plastic Pollution",
                description: "Report plastic waste and debris",
                type: .waste,
                category: .marine,
                requiredFields: [
                    ReportField(name: "Location", type: .location, isRequired: true, placeholder: "Enter location", options: nil, validation: nil),
                    ReportField(name: "Description", type: .textArea, isRequired: true, placeholder: "Describe the plastic pollution", options: nil, validation: ValidationRule(minLength: 10, maxLength: 500, minValue: nil, maxValue: nil, pattern: nil, customMessage: nil)),
                    ReportField(name: "Photos", type: .image, isRequired: true, placeholder: "Take photos", options: nil, validation: nil)
                ],
                optionalFields: [
                    ReportField(name: "Estimated Amount", type: .singleChoice, isRequired: false, placeholder: "Select amount", options: ["Small", "Medium", "Large", "Massive"], validation: nil),
                    ReportField(name: "Weather Conditions", type: .singleChoice, isRequired: false, placeholder: "Select weather", options: ["Clear", "Cloudy", "Rainy", "Stormy"], validation: nil)
                ],
                guidelines: [
                    "Take clear photos showing the pollution",
                    "Include location details",
                    "Note any wildlife affected"
                ],
                examples: [
                    "Plastic bottles scattered across 100m of beach",
                    "Microplastics mixed with sand",
                    "Fishing gear entangled in rocks"
                ],
                isActive: true
            )
        ]
    }
    
    private func loadNotifications() {
        notifications = [
            ReportNotification(
                reportId: UUID(),
                type: .statusUpdate,
                title: "Report Status Updated",
                message: "Your plastic pollution report has been verified",
                timestamp: Date().addingTimeInterval(-3600),
                isRead: false,
                actionUrl: nil
            ),
            ReportNotification(
                reportId: UUID(),
                type: .analysisComplete,
                title: "Analysis Complete",
                message: "Analysis results are available for your oil spill report",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: true,
                actionUrl: nil
            )
        ]
    }
    
    private func updateFilteredReports() {
        if searchText.isEmpty {
            filteredReports = reports
        } else {
            searchReports(query: searchText)
        }
    }
}
