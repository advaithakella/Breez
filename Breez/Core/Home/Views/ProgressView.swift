import SwiftUI

struct ProgressScreen: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Progress View")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text("This is the progress screen")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

#Preview {
    ProgressScreen()
        .background(Color.black)
}
