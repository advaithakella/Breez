import SwiftUI

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
            
            Text(value)
                .font(.proximaNovaSemibold(size: 20))
                .foregroundColor(.white)
            
            Text(title)
                .font(.proximaNovaSemibold(size: 12))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Activity Row
struct ActivityRow: View {
    let activity: Activity
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: categoryIcon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.title)
                    .font(.proximaNovaSemibold(size: 16))
                    .foregroundColor(.white)
                
                Text(activity.description)
                    .font(.proximaNovaSemibold(size: 14))
                    .foregroundColor(.white)
                    .lineLimit(2)
                
                HStack(spacing: 16) {
            if activity.impact.carbonSaved > 0 {
                HStack(spacing: 4) {
                    Image(systemName: Ph.leaf)
                        .font(.system(size: 12))
                        .foregroundColor(.green.opacity(0.85))
                    Text("\(String(format: "%.1f", activity.impact.carbonSaved))kg CO2")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
            }
                    
            if activity.impact.plasticAvoided > 0 {
                HStack(spacing: 4) {
                    Image(systemName: Ph.trash)
                        .font(.system(size: 12))
                        .foregroundColor(.blue.opacity(0.85))
                    Text("\(activity.impact.plasticAvoided) items")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
            }
                }
            }
            
            Spacer()
            
            // Status
            VStack(spacing: 4) {
                Image(systemName: activity.isCompleted ? Ph.checkCircle : "circle")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                Text(timeAgo)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var categoryIcon: String {
        switch activity.category {
        case .transportation: return "car.fill"
        case .energy: return "bolt.fill"
        case .waste: return "trash.fill"
        case .water: return "drop.fill"
        case .food: return "fork.knife"
        case .lifestyle: return "person.fill"
        }
    }
    
    private var categoryColor: Color {
        switch activity.category {
        case .transportation: return .blue
        case .energy: return .yellow
        case .waste: return .red
        case .water: return .cyan
        case .food: return .green
        case .lifestyle: return .purple
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: activity.timestamp, relativeTo: Date())
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    let activity: Activity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
            Image(systemName: categoryIcon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(.white)
                
                Text(activity.category.rawValue)
                    .font(.proximaNovaSemibold(size: 14))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(timeAgo)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
            }
            
            Text(activity.title)
                .font(.proximaNovaSemibold(size: 18))
                .foregroundColor(.white)
            
            Text(activity.description)
                .font(.proximaNovaSemibold(size: 14))
                .foregroundColor(.white)
                .lineLimit(3)
            
            // Impact Summary
            HStack(spacing: 20) {
                if activity.impact.carbonSaved > 0 {
                    ImpactBadge(
                        icon: "leaf.fill",
                        value: "\(String(format: "%.1f", activity.impact.carbonSaved))kg",
                        label: "CO2",
                        color: .green
                    )
                }
                
                if activity.impact.plasticAvoided > 0 {
                    ImpactBadge(
                        icon: "trash.fill",
                        value: "\(activity.impact.plasticAvoided)",
                        label: "items",
                        color: .blue
                    )
                }
                
                if activity.impact.waterSaved > 0 {
                    ImpactBadge(
                        icon: "drop.fill",
                        value: "\(String(format: "%.0f", activity.impact.waterSaved))L",
                        label: "water",
                        color: .cyan
                    )
                }
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var categoryIcon: String {
        switch activity.category {
        case .transportation: return "car.fill"
        case .energy: return "bolt.fill"
        case .waste: return "trash.fill"
        case .water: return "drop.fill"
        case .food: return "fork.knife"
        case .lifestyle: return "person.fill"
        }
    }
    
    private var categoryColor: Color {
        switch activity.category {
        case .transportation: return .blue
        case .energy: return .yellow
        case .waste: return .red
        case .water: return .cyan
        case .food: return .green
        case .lifestyle: return .purple
        }
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: activity.timestamp, relativeTo: Date())
    }
}

// MARK: - Impact Badge
struct ImpactBadge: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(
                    label.lowercased() == "co2" ? .green.opacity(0.85) :
                    (label.lowercased().contains("water") ? .cyan.opacity(0.85) :
                    (label.lowercased().contains("item") ? .blue.opacity(0.85) : .white))
                )
            
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.proximaNovaSemibold(size: 12))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.proximaNovaSemibold(size: 10))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.proximaNovaSemibold(size: 12))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(18)
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.3), lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Challenge Card
struct ChallengeCard: View {
    let challenge: Challenge
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(challenge.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(challenge.description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white)
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(challenge.difficulty.rawValue)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    
                    Text("\(challenge.duration) days")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                }
            }
            
            // Progress Bar
            if challenge.isActive {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        Text("\(Int(challenge.progress * 100))%")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    SwiftUI.ProgressView(value: challenge.progress)
                        .tint(.white)
                        .scaleEffect(y: 2)
                        .padding(.top, 8)
                }
            }
            
            // Requirements
            VStack(alignment: .leading, spacing: 4) {
                Text("Requirements:")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                
                ForEach(challenge.requirements.prefix(3), id: \.self) { requirement in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                        
                        Text(requirement)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white)
                    }
                }
            }
            
            // Action Button
            HStack {
                Spacer()
                
                Button(action: {
                    // Handle challenge action
                }) {
                    Text(challenge.isActive ? "Continue" : "Join Challenge")
                        .font(.proximaNovaSemibold(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var difficultyColor: Color {
        switch challenge.difficulty {
        case .easy: return .green
        case .medium: return .yellow
        case .hard: return .orange
        case .expert: return .red
        }
    }
}

// MARK: - Community Stat Card
struct CommunityStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Community Post Card
struct CommunityPostCard: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 12) {
                // Avatar
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.white.opacity(0.6))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(timeAgo)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Spacer()
            }
            
            // Content
            Text(post.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.white)
                .lineLimit(nil)
            
            // Image (if available)
            if let imageURL = post.imageURL {
                AsyncImage(url: URL(string: imageURL)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(height: 200)
                .cornerRadius(8)
            }
            
            // Actions
            HStack(spacing: 20) {
                Button(action: {
                    // Handle like
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .font(.system(size: 16))
                            .foregroundColor(post.isLiked ? .red : .white.opacity(0.6))
                        
                        Text("\(post.likes)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // Handle comment
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(post.comments)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    // Handle share
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                        
                        Text("\(post.shares)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1)) // Match onboarding unselected answer
        .cornerRadius(18)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: Color.black.opacity(0.10), radius: 10, x: 0, y: 4)
    }
    
    private var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: post.timestamp, relativeTo: Date())
    }
}
