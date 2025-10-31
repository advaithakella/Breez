import SwiftUI

struct NavBar: View {
    @Binding var selectedTab: Tab
    @State private var showComingSoonAlert = false

    enum Tab {
        case home, explore, reports
    }

    var body: some View {
        HStack {
            navItem(
                icon: Image(systemName: "house.fill").foregroundColor(.white),
                label: "home",
                selected: selectedTab == .home,
                size: 44
            ) { selectedTab = .home }
            Spacer()
            navItem(
                icon: Image(systemName: "leaf.fill").foregroundColor(.white),
                label: "explore",
                selected: selectedTab == .explore,
                size: 44
            ) { selectedTab = .explore }
            Spacer()
            navItem(
                icon: Image(systemName: "doc.plaintext").foregroundColor(.white),
                label: "reports",
                selected: selectedTab == .reports,
                size: 44
            ) { selectedTab = .reports }
        }
        .padding(.horizontal, 60)
        .padding(.vertical, 12)
        .background(Color(hex: "7DC7FF").ignoresSafeArea(edges: .bottom))
        .zIndex(10)
        .alert("Feature Coming Soon!", isPresented: $showComingSoonAlert) {
            Button("OK") {}
        } message: {
            Text("This feature is currently in development. Thank you for your patience! ❤️")
        }
    }

    @ViewBuilder
    private func navItem(icon: some View, label: String, selected: Bool, size: CGFloat = 10, backgroundColor: Color? = nil, action: @escaping () -> Void) -> some View {
        VStack(spacing: 6) {
            let bgColor = Color.white.opacity(0.1)
            let textColor = Color.white
            
            Icon(icon: icon, size: size, backgroundColor: bgColor, action: action)
                .shadow(color: selected ? Color(hex: "FFCC8E").opacity(0.3) : .clear, radius: 8, x: 0, y: 2)
            
            if !label.isEmpty {
                Text(label)
                    .font(.proximaNovaSemibold(size: 10))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    @Previewable
    @State var selectedTab: NavBar.Tab = .home
    
    VStack {
        NavBar(selectedTab: $selectedTab)
        
        Spacer()
        
        Text("Selected: \(String(describing: selectedTab))")
            .font(.caption)
            .foregroundColor(.subtext)
    }
    .padding()
    .background(Color(hex: "7DC7FF"))
}