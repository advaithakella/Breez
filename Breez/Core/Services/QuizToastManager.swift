import SwiftUI

class QuizToastManager: ObservableObject {
    @Published var isShowing = false
    @Published var message = ""
    
    func showToast(message: String) {
        self.message = message
        self.isShowing = true
        
        // Auto-hide after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isShowing = false
        }
    }
}
