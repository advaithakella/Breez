import SwiftUI

struct LogsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Logs View")
                .font(.largeTitle)
                .foregroundColor(.white)
            
            Text("This is the logs screen")
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
    LogsView()
        .background(Color.black)
}
