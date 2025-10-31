import Foundation

class ExploreViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var resources: [Resource] = []
    @Published var filteredResources: [Resource] = []
    @Published var hotActions: [Resource] = []
    @Published var events: [Event] = []
    @Published var actions: [Action] = []
    @Published var educationResources: [EducationResource] = []
    @Published var bookmarks: [Bookmark] = []
    @Published var wishlist: [Wishlist] = []
    @Published var searchText = ""
    @Published var currentFilters = SearchFilters()
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
    
    func refreshResources() {
        loadData()
    }
    
    func searchResources(query: String) {
        searchText = query
        
        if query.isEmpty {
            filteredResources = resources
        } else {
            filteredResources = resources.filter { resource in
                resource.title.localizedCaseInsensitiveContains(query) ||
                resource.description.localizedCaseInsensitiveContains(query) ||
                resource.organization.localizedCaseInsensitiveContains(query)
            }
        }
    }
    
    func filterResources(by filter: String) {
        if filter == "All" {
            filteredResources = resources
        } else {
            filteredResources = resources.filter { $0.type.rawValue == filter }
        }
    }
    
    func applyFilters(_ filters: SearchFilters) {
        currentFilters = filters
        
        var filtered = resources
        
        // Apply category filter
        if !filters.categories.isEmpty {
            filtered = filtered.filter { filters.categories.contains($0.category) }
        }
        
        // Apply type filter
        if !filters.types.isEmpty {
            filtered = filtered.filter { filters.types.contains($0.type) }
        }
        
        // Apply difficulty filter
        if !filters.difficulty.isEmpty {
            filtered = filtered.filter { filters.difficulty.contains($0.difficulty) }
        }
        
        // Apply free filter
        if let isFree = filters.isFree {
            filtered = filtered.filter { $0.type == .event ? true : !isFree } // Simplified for demo
        }
        
        // Apply location filter
        if let location = filters.location, !location.isEmpty {
            filtered = filtered.filter { $0.location?.localizedCaseInsensitiveContains(location) == true }
        }
        
        // Apply sorting
        switch filters.sortBy {
        case .relevance:
            filtered = filtered.sorted { $0.likes > $1.likes }
        case .date:
            filtered = filtered.sorted { ($0.date ?? Date.distantPast) > ($1.date ?? Date.distantPast) }
        case .popularity:
            filtered = filtered.sorted { $0.likes > $1.likes }
        case .rating:
            filtered = filtered.sorted { $0.likes > $1.likes } // Using likes as proxy for rating
        case .distance:
            filtered = filtered.sorted { $0.likes > $1.likes } // Would need location data for real distance sorting
        }
        
        filteredResources = filtered
    }
    
    func bookmarkResource(_ resource: Resource) {
        let bookmark = Bookmark(
            resourceId: resource.id,
            resourceType: resource.type.rawValue,
            title: resource.title,
            organization: resource.organization,
            imageUrl: resource.imageUrl,
            dateAdded: Date()
        )
        bookmarks.append(bookmark)
    }
    
    func removeBookmark(_ resourceId: UUID) {
        bookmarks.removeAll { $0.resourceId == resourceId }
    }
    
    func addToWishlist(_ resource: Resource, priority: Wishlist.Priority = .medium) {
        let wishlistItem = Wishlist(
            resourceId: resource.id,
            resourceType: resource.type.rawValue,
            title: resource.title,
            organization: resource.organization,
            imageUrl: resource.imageUrl,
            dateAdded: Date(),
            priority: priority
        )
        wishlist.append(wishlistItem)
    }
    
    func removeFromWishlist(_ resourceId: UUID) {
        wishlist.removeAll { $0.resourceId == resourceId }
    }
    
    func likeResource(_ resource: Resource) {
        if let index = resources.firstIndex(where: { $0.id == resource.id }) {
            var updatedResource = resource
            updatedResource.isLiked.toggle()
            updatedResource.likes += updatedResource.isLiked ? 1 : -1
            resources[index] = updatedResource
            updateFilteredResources()
        }
    }
    
    // MARK: - Private Methods
    private func loadMockData() {
        loadResources()
        loadEvents()
        loadActions()
        loadEducationResources()
        loadHotActions()
        filterResources(by: "All")
    }
    
    private func loadResources() {
        resources = [
            Resource(
                title: "Beach Cleanup Event",
                description: "Join local volunteers for monthly beach cleanups at Santa Monica Beach. Help protect marine life and keep our beaches beautiful.",
                organization: "Surfrider Foundation",
                type: .event,
                category: .ocean,
                imageUrl: "https://example.com/cleanup1.jpg",
                location: "Santa Monica Beach, CA",
                date: Date().addingTimeInterval(86400 * 7),
                likes: 156,
                isLiked: false,
                isBookmarked: false,
                difficulty: .beginner,
                duration: "3 hours",
                requirements: ["Bring gloves", "Wear comfortable shoes", "Water bottle"],
                impact: EnvironmentalImpact(carbonSaved: 0.5, plasticAvoided: 50, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "volunteer@surfrider.org", phone: "(555) 123-4567", socialMedia: ["instagram": "@surfrider"]),
                website: "https://surfrider.org"
            ),
            Resource(
                title: "Ocean Conservation Petition",
                description: "Sign petition to protect marine sanctuaries from oil drilling. Your voice matters in protecting our oceans.",
                organization: "Ocean Conservancy",
                type: .action,
                category: .ocean,
                imageUrl: "https://example.com/petition1.jpg",
                location: nil,
                date: nil,
                likes: 89,
                isLiked: false,
                isBookmarked: false,
                difficulty: .beginner,
                duration: "5 minutes",
                requirements: ["Email address", "Name"],
                impact: EnvironmentalImpact(carbonSaved: 0.1, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "action@oceanconservancy.org", phone: nil, socialMedia: ["twitter": "@oceanconservancy"]),
                website: "https://oceanconservancy.org"
            ),
            Resource(
                title: "Marine Biology Workshop",
                description: "Learn about local marine ecosystems and conservation techniques. Perfect for students and nature enthusiasts.",
                organization: "Aquarium of the Pacific",
                type: .education,
                category: .ocean,
                imageUrl: "https://example.com/workshop1.jpg",
                location: "Long Beach, CA",
                date: Date().addingTimeInterval(86400 * 14),
                likes: 67,
                isLiked: false,
                isBookmarked: false,
                difficulty: .intermediate,
                duration: "2 days",
                requirements: ["Basic biology knowledge", "Notebook", "Camera"],
                impact: EnvironmentalImpact(carbonSaved: 0.2, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "education@aquariumofpacific.org", phone: "(562) 590-3100", socialMedia: nil),
                website: "https://aquariumofpacific.org"
            ),
            Resource(
                title: "Plastic-Free Challenge",
                description: "30-day challenge to reduce plastic use in daily life. Join thousands of participants worldwide.",
                organization: "Plastic Free July",
                type: .campaign,
                category: .waste,
                imageUrl: "https://example.com/challenge1.jpg",
                location: nil,
                date: Date().addingTimeInterval(86400 * 30),
                likes: 234,
                isLiked: false,
                isBookmarked: false,
                difficulty: .intermediate,
                duration: "30 days",
                requirements: ["Commitment to reduce plastic", "Reusable alternatives"],
                impact: EnvironmentalImpact(carbonSaved: 2.0, plasticAvoided: 100, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "info@plasticfreejuly.org", phone: nil, socialMedia: ["facebook": "PlasticFreeJuly"]),
                website: "https://plasticfreejuly.org"
            ),
            Resource(
                title: "Coastal Restoration Project",
                description: "Help restore native plants and dunes along the coast. Learn about ecosystem restoration.",
                organization: "California Coastal Commission",
                type: .volunteer,
                category: .biodiversity,
                imageUrl: "https://example.com/restoration1.jpg",
                location: "Malibu, CA",
                date: Date().addingTimeInterval(86400 * 21),
                likes: 112,
                isLiked: false,
                isBookmarked: false,
                difficulty: .intermediate,
                duration: "4 hours",
                requirements: ["Physical fitness", "Work gloves", "Sun protection"],
                impact: EnvironmentalImpact(carbonSaved: 1.0, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "volunteer@coastal.ca.gov", phone: "(415) 904-5200", socialMedia: nil),
                website: "https://coastal.ca.gov"
            ),
            Resource(
                title: "Climate Action Rally",
                description: "Join the movement for climate action and environmental justice. Make your voice heard.",
                organization: "350.org",
                type: .action,
                category: .climate,
                imageUrl: "https://example.com/rally1.jpg",
                location: "Los Angeles, CA",
                date: Date().addingTimeInterval(86400 * 10),
                likes: 445,
                isLiked: false,
                isBookmarked: false,
                difficulty: .beginner,
                duration: "2 hours",
                requirements: ["Comfortable walking shoes", "Water bottle", "Signs welcome"],
                impact: EnvironmentalImpact(carbonSaved: 0.1, plasticAvoided: 0, waterSaved: 0, energySaved: 0),
                contactInfo: ContactInfo(email: "info@350.org", phone: nil, socialMedia: ["twitter": "@350"]),
                website: "https://350.org"
            )
        ]
    }
    
    private func loadEvents() {
        events = [
            Event(
                title: "Monthly Beach Cleanup",
                description: "Regular beach cleanup event at Venice Beach",
                organization: "Heal the Bay",
                location: "Venice Beach, CA",
                startDate: Date().addingTimeInterval(86400 * 7),
                endDate: Date().addingTimeInterval(86400 * 7 + 10800),
                imageUrl: "https://example.com/event1.jpg",
                maxParticipants: 50,
                currentParticipants: 23,
                price: 0,
                isFree: true,
                requirements: ["Gloves", "Comfortable shoes"],
                contactInfo: ContactInfo(email: "volunteer@healthebay.org", phone: "(310) 451-1500", socialMedia: nil),
                website: "https://healthebay.org",
                isBookmarked: false,
                isRegistered: false
            )
        ]
    }
    
    private func loadActions() {
        actions = [
            Action(
                title: "Stop Single-Use Plastics Campaign",
                description: "Advocate for local legislation to ban single-use plastics",
                organization: "Surfrider Foundation",
                type: .advocacy,
                location: "Los Angeles, CA",
                imageUrl: "https://example.com/action1.jpg",
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 90),
                isOngoing: true,
                participants: 1250,
                goal: "5000 signatures",
                progress: 0.25,
                impact: EnvironmentalImpact(carbonSaved: 5.0, plasticAvoided: 1000, waterSaved: 0, energySaved: 0),
                requirements: ["Email address", "Resident of LA County"],
                contactInfo: ContactInfo(email: "action@surfrider.org", phone: nil, socialMedia: nil),
                website: "https://surfrider.org",
                isBookmarked: false,
                isJoined: false
            )
        ]
    }
    
    private func loadEducationResources() {
        educationResources = [
            EducationResource(
                title: "Introduction to Marine Conservation",
                description: "Comprehensive course on marine ecosystem protection",
                organization: "Scripps Institution of Oceanography",
                type: .course,
                category: .ocean,
                imageUrl: "https://example.com/course1.jpg",
                duration: "6 weeks",
                difficulty: .beginner,
                language: "English",
                isFree: true,
                price: 0,
                rating: 4.8,
                reviews: 156,
                modules: [
                    EducationModule(title: "Ocean Basics", description: "Introduction to ocean ecosystems", duration: "1 week", isCompleted: false, order: 1),
                    EducationModule(title: "Threats to Marine Life", description: "Understanding current threats", duration: "1 week", isCompleted: false, order: 2)
                ],
                requirements: ["Basic science knowledge"],
                certificate: true,
                contactInfo: ContactInfo(email: "education@scripps.ucsd.edu", phone: nil, socialMedia: nil),
                website: "https://scripps.ucsd.edu",
                isBookmarked: false,
                isEnrolled: false
            )
        ]
    }
    
    private func loadHotActions() {
        hotActions = Array(resources.sorted { $0.likes > $1.likes }.prefix(3))
    }
    
    private func updateFilteredResources() {
        if searchText.isEmpty {
            filteredResources = resources
        } else {
            searchResources(query: searchText)
        }
    }
}
