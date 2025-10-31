import Foundation

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var currentDay: Int = 1
    @Published var currentStreak: Int = 0
    
    private init() {
        // Initialize user manager
    }

    func clearUserData() {
        currentDay = 1
        currentStreak = 0
    }
}