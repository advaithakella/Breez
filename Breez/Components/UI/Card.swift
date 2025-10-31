import SwiftUI

struct CardView<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    let content: Content
    let borderColor: String
    let borderWidth: CGFloat

    init(width: CGFloat, height: CGFloat, borderColor: String = "D0CAB6", borderWidth: CGFloat = 2, @ViewBuilder content: () -> Content) {
        self.width = width
        self.height = height
        self.content = content()
        self.borderColor = borderColor
        self.borderWidth = borderWidth
    }

    var body: some View {
        // Ensure the card never exceeds the screen width minus a small margin
        let maxAllowedWidth = UIScreen.main.bounds.width - 40
        let finalWidth = min(width, maxAllowedWidth)

        return ZStack {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(width: finalWidth, height: height)
    .background(Color(hex: "F5F3F0"))
    .cornerRadius(20)
    .overlay(
        RoundedRectangle(cornerRadius: 20)
            .stroke(Color(hex: borderColor), lineWidth: borderWidth)
    )
    }
}

#Preview {
    VStack(spacing: 20) {
        CardView(width: 300, height: 150) {
            VStack {
                Text("Sample Card")
                    .font(.headline)
                    .foregroundColor(.white)
                Text("This is a preview of the card component")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
        
        CardView(width: 200, height: 100) {
            Text("Small Card")
                .font(.subheadline)
                .foregroundColor(.white)
        }
        
        CardView(width: 350, height: 200) {
            VStack(spacing: 10) {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.largeTitle)
                Text("Featured Content")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                Text("This card demonstrates how content flows within the card component")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}