import Foundation

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isCheckingSubscription = false
    @Published var isConverted = false
    
    private init() {
        // Initialize subscription manager
    }
    
    func refreshSubscriptionStatus() {
        // Refresh subscription status
        isCheckingSubscription = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isCheckingSubscription = false
            self.isConverted = true
        }
    }
    
    func clearSubscriptionData() {
        isConverted = false
        isCheckingSubscription = false
    }
}
