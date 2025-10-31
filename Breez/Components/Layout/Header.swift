import SwiftUI
import UIKit

struct Header: View {
    @State private var showSettings = false
    let currentTab: NavBar.Tab
    let onLogout: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            Text("BREEZ")
                .font(.frijole(size: 20))
                .foregroundColor(.white)
                .shadow(color: Color.white.opacity(0.25), radius: 6, x: 0, y: 0)
                .padding(.top, 10)
            Spacer()
            Button {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred(intensity: 0.6)
                showSettings = true
            } label: {
                Icon(
                    icon: Image(systemName: Ph.gear).foregroundColor(.white),
                    size: 28,
                    backgroundColor: Color.white.opacity(0.1)
                )
            }
            .buttonStyle(.plain)
        }
        .frame(height: 44)
        .padding(.horizontal, 30)
        .padding(.vertical, 0)
        .background(Color.clear)
        .sheet(isPresented: $showSettings) {
            SettingsView(onLogout: {
                showSettings = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onLogout()
                }
            })
            .presentationDetents([.height(460)])
            .presentationDragIndicator(.hidden)
            .presentationCornerRadius(30)
            .presentationBackground(.clear)
            .interactiveDismissDisabled(false)
        }
        .zIndex(10)
    }
    
    // headerSubtitle removed
}

#Preview {
    VStack(spacing: 20) {
        Header(currentTab: .home, onLogout: {})
        Header(currentTab: .explore, onLogout: {})
        Header(currentTab: .reports, onLogout: {})
    }
    .background(Color(hex: "7DC7FF"))
}
