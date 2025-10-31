import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedTab: HomeTab = .dashboard
    
    enum HomeTab: CaseIterable {
        case dashboard, activities, challenges, community
        
        var title: String {
            switch self {
            case .dashboard: return "Dashboard"
            case .activities: return "Activities"
            case .challenges: return "Challenges"
            case .community: return "Community"
            }
        }
        
        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .activities: return "list.bullet"
            case .challenges: return "trophy.fill"
            case .community: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            HStack(spacing: 0) {
                ForEach(HomeTab.allCases, id: \.self) { tab in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedTab = tab
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: tab.icon)
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                            
                            Text(tab.title)
                                .font(.proximaNovaSemibold(size: 12))
                                .foregroundColor(selectedTab == tab ? .white : .white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .background(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(12)
            .padding(.horizontal, 20)
            .padding(.top, 10)
            
            // Content
            TabView(selection: $selectedTab) {
                DashboardView()
                    .tag(HomeTab.dashboard)
                
                ActivitiesView()
                    .tag(HomeTab.activities)
                
                ChallengesView()
                    .tag(HomeTab.challenges)
                
                CommunityView()
                    .tag(HomeTab.community)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Welcome Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Welcome back!")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Track your environmental impact today")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // Stats Cards
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    StatCard(
                        title: "Carbon Saved",
                        value: "2.4 kg",
                        icon: "leaf.fill",
                        color: .green
                    )
                    
                    StatCard(
                        title: "Plastic Avoided",
                        value: "12 items",
                        icon: "trash.fill",
                        color: .blue
                    )
                    
                    StatCard(
                        title: "Water Saved",
                        value: "45L",
                        icon: "drop.fill",
                        color: .cyan
                    )
                    
                    StatCard(
                        title: "Streak",
                        value: "7 days",
                        icon: "flame.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal, 20)
                
                // Recent Activities
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Activities")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.recentActivities, id: \.id) { activity in
                            ActivityRow(activity: activity)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 16) {
                    Text("Quick Actions")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        QuickActionButton(
                            title: "Log Activity",
                            icon: "plus.circle.fill",
                            color: .green
                        ) {
                            // Handle log activity
                        }
                        
                        QuickActionButton(
                            title: "Report Issue",
                            icon: "exclamationmark.triangle.fill",
                            color: .red
                        ) {
                            // Handle report issue
                        }
                        
                        QuickActionButton(
                            title: "Join Challenge",
                            icon: "trophy.fill",
                            color: .yellow
                        ) {
                            // Handle join challenge
                        }
                        
                        QuickActionButton(
                            title: "View Progress",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .blue
                        ) {
                            // Handle view progress
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Activities View
struct ActivitiesView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedCategory: ActivityCategory = .all
    
    enum ActivityCategory: String, CaseIterable {
        case all = "All"
        case transportation = "Transportation"
        case energy = "Energy"
        case waste = "Waste"
        case water = "Water"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.proximaNovaSemibold(size: 14))
                                .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.7))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 16)
            
            // Activities List
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(filteredActivities, id: \.id) { activity in
                        ActivityCard(activity: activity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 100)
            }
        }
    }

    private var filteredActivities: [Activity] {
        let base: [Activity]
        switch selectedCategory {
        case .all:
            base = viewModel.activities
        case .transportation:
            base = viewModel.activities.filter { $0.category == .transportation }
        case .energy:
            base = viewModel.activities.filter { $0.category == .energy }
        case .waste:
            base = viewModel.activities.filter { $0.category == .waste }
        case .water:
            base = viewModel.activities.filter { $0.category == .water }
        }
        return base.sorted(by: { $0.timestamp > $1.timestamp })
    }
}

// MARK: - Challenges View
struct ChallengesView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Active Challenges
                VStack(alignment: .leading, spacing: 16) {
                    Text("Active Challenges")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.activeChallenges, id: \.id) { challenge in
                            ChallengeCard(challenge: challenge)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Available Challenges
                VStack(alignment: .leading, spacing: 16) {
                    Text("Available Challenges")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.availableChallenges, id: \.id) { challenge in
                            ChallengeCard(challenge: challenge)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

// MARK: - Community View
struct CommunityView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Community Stats
                VStack(spacing: 16) {
                    Text("Community Impact")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        CommunityStatCard(
                            title: "Total Members",
                            value: "1,234",
                            icon: "person.3.fill"
                        )
                        
                        CommunityStatCard(
                            title: "CO2 Saved",
                            value: "2.4 tons",
                            icon: "leaf.fill"
                        )
                        
                        CommunityStatCard(
                            title: "Plastic Avoided",
                            value: "5,678 items",
                            icon: "trash.fill"
                        )
                        
                        CommunityStatCard(
                            title: "Water Saved",
                            value: "12,345L",
                            icon: "drop.fill"
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // Recent Posts
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Posts")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.communityPosts, id: \.id) { post in
                            CommunityPostCard(post: post)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
        }
    }
}

#Preview {
    HomeView()
        .background(Color.black)
}