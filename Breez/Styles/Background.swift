import SwiftUI

struct AppBackground: View {
    var body: some View {
        Color.black
            .ignoresSafeArea(.all)
    }
}

struct GradientBackground: View {
    var body: some View {
        ZStack {
            // White background
            Color.white
                .ignoresSafeArea(.all)
            
            // Orange to blue gradient overlay
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFCC8E"), location: 0.23),
                    .init(color: Color(hex: "7DC7FF"), location: 0.82)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.1)
            .ignoresSafeArea(.all)
        }
    }
}

// Preview removed for production build stability
