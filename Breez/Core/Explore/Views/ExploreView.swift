import SwiftUI

struct ExploreView: View {
    @StateObject private var exploreViewModel = ExploreViewModel()
    @State private var searchText = ""
    @State private var selectedFilter = "All"
    @State private var selectedResource: Resource?
    
    private let filters = ["All", "Events", "Actions", "Education", "Cleanups"]
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFCC8E"), location: 0.23),
                    .init(color: Color(hex: "7DC7FF"), location: 0.82)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing)
            .ignoresSafeArea()

            // Rebuilt like Home: gradient under a ScrollView with glass cards
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Title removed per request

                    // Search bar
                    SearchBar(text: $searchText)
                        .padding(.horizontal, 20)

                    // Filter chips
                    ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                            ForEach(filters, id: \.self) { filter in
                                FilterButton(title: filter, isSelected: selectedFilter == filter) {
                                    selectedFilter = filter
                                    exploreViewModel.filterResources(by: filter)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Hot actions
                    if !exploreViewModel.hotActions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Hot Actions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Button("View All") {}
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 20)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(exploreViewModel.hotActions) { action in
                                        HotActionCard(action: action) { selectedResource = action }
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }

                    // Resource list as glass cards
                    VStack(spacing: 12) {
                        ForEach(exploreViewModel.filteredResources) { resource in
                            ResourceCard(resource: resource) { selectedResource = resource }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .padding(.top, 8)
            }
        }
        .sheet(item: $selectedResource) { resource in
            ResourceDetailView(resource: resource)
        }
        // ViewModel loads data on init; no explicit call needed
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: Ph.magnifyingGlass)
                .foregroundColor(.white.opacity(0.8))
            
            TextField("Search resources...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .foregroundColor(.white)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(10)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
                .cornerRadius(20)
        }
    }
}

struct HotActionCard: View {
    let action: Resource
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: action.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                }
                .frame(width: 200, height: 120)
                .cornerRadius(18)
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.3), lineWidth: 2)
                )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(action.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(action.organization)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    HStack {
                        Image(systemName: Ph.flame)
                            .foregroundColor(.white)
                            .font(.caption)
                        
                        Text("Hot")
                            .font(.caption)
                            .foregroundColor(.white)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("\(action.likes) likes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(width: 200)
    }
}

struct ResourceCard: View {
    let resource: Resource
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                AsyncImage(url: URL(string: resource.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(resource.title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)
                    
                    Text(resource.organization)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(resource.description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                    
                    HStack {
                        Text(resource.type.rawValue)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .cornerRadius(4)
                        
                        Spacer()
                        
                        Text("\(resource.likes) likes")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(12)
            .background(Color.white.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
            )
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

struct EmptyResourcesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: Ph.magnifyingGlass)
                .font(.system(size: 60))
                .foregroundColor(.white.opacity(0.7))
            
            Text("No Resources Found")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Try adjusting your search or filters")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
}

struct ResourceDetailView: View {
    let resource: Resource
    @Environment(\.dismiss) private var dismiss
    @State private var isLiked = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header image
                    AsyncImage(url: URL(string: resource.imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.white.opacity(0.15))
                            .frame(height: 200)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    
                    // Basic info
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(resource.title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text("by \(resource.organization)")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                isLiked.toggle()
                            }) {
                                Image(systemName: isLiked ? Ph.heart : Ph.heartOutline)
                                    .font(.title2)
                                    .foregroundColor(isLiked ? .red : .white)
                            }
                        }
                        
                        Text(resource.description)
                            .font(.body)
                        
                        HStack {
                            Text(resource.type.rawValue)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: "7DC7FF"))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                            
                            Spacer()
                            
                            Text("\(resource.likes) likes")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            // Add to wishlist
                        }) {
                            HStack {
                                Image(systemName: Ph.bookmarkOutline)
                                Text("Add to Wishlist")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "7DC7FF"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            // Join now
                        }) {
                            HStack {
                                Image(systemName: Ph.caretRight)
                                Text("Join Now")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "7DC7FF"))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Resource Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ExploreView()
}
