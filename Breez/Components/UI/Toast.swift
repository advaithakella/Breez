import SwiftUI

struct ToastView: View {
    @ObservedObject var toastManager: QuizToastManager
    
    var body: some View {
        Text(toastManager.message)
            .font(.sohne(.bold, size: 14))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(hex: "1C1C1C"))
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color(hex: "3A3A3A"), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ToastView(toastManager: QuizToastManager())
        .background(Color.black)
}