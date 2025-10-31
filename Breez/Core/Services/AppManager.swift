import Foundation
import Combine
import SwiftUI
import CoreLocation

// MARK: - App Manager
class AppManager: ObservableObject {
    static let shared = AppManager()
    
    // MARK: - Published Properties
    @Published var isInitialized = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var appState: AppState = .launching
    
    // MARK: - Services
    let networkService = NetworkService.shared
    let locationService = LocationService.shared
    let analyticsService = AnalyticsService.shared
    let notificationService = NotificationService.shared
    let firebaseAuthService = FirebaseAuthService.shared
    let firebaseFirestoreService = FirebaseFirestoreService.shared
    let firebaseImageService = FirebaseImageService.shared
    let userManager = UserManager.shared
    let subscriptionManager = SubscriptionManager.shared
    let quizToastManager = QuizToastManager()
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupBindings()
    }
    
    // MARK: - Initialization
    func initialize() {
        guard !isInitialized else { return }
        
        isLoading = true
        appState = .initializing
        
        // Initialize services in sequence
        Task {
            await initializeServices()
            
            await MainActor.run {
                self.isInitialized = true
                self.isLoading = false
                self.appState = .ready
            }
        }
    }
    
    private func initializeServices() async {
        // Initialize analytics first
        analyticsService.requestUserConsent()
        analyticsService.trackAppLaunch()
        
        // Initialize location services
        locationService.requestLocationPermission()
        
        // Initialize notifications
        notificationService.requestPermission()
        notificationService.setupNotificationCategories()
        
        // Firebase services are ready after FirebaseApp.configure(); no explicit initialize required
        
        // Load user data if needed (not implemented)
        
        // No subscription flow; skip
        
        // Schedule default notifications
        scheduleDefaultNotifications()
    }
    
    // MARK: - App Lifecycle
    func appDidBecomeActive() {
        analyticsService.trackAppForeground()
        locationService.startLocationUpdates()
        notificationService.clearBadgeCount()
    }
    
    func appDidEnterBackground() {
        analyticsService.trackAppBackground()
        locationService.stopLocationUpdates()
    }
    
    func appWillTerminate() {
        // Clean up resources
        locationService.stopLocationUpdates()
    }
    
    // MARK: - Error Handling
    func handleError(_ error: Error, context: String) {
        errorMessage = error.localizedDescription
        analyticsService.trackError(error, context: context)
        
        // Auto-dismiss error after 5 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.errorMessage = nil
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - User Actions
    func logOut() {
        Task {
            await MainActor.run {
                try? firebaseAuthService.signOut()
            }
            // Reset minimal user state
            self.userManager.currentDay = 1
            self.userManager.currentStreak = 0
            subscriptionManager.clearSubscriptionData()
            
            await MainActor.run {
                self.appState = .loggedOut
            }
        }
    }
    
    func resetApp() {
        // Clear all user data
        userManager.clearUserData()
        subscriptionManager.clearSubscriptionData()
        analyticsService.clearStoredEvents()
        notificationService.cancelAllNotifications()
        
        // Reset app state
        appState = .launching
        isInitialized = false
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Monitor network status
        networkService.$isConnected
            .sink { [weak self] isConnected in
                if !isConnected {
                    self?.handleError(NetworkError.noConnection, context: "NetworkService")
                }
            }
            .store(in: &cancellables)
        
        // Monitor location errors
        locationService.$locationError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleError(error, context: "LocationService")
            }
            .store(in: &cancellables)
        
        // Monitor user manager changes
        userManager.$currentDay
            .sink { [weak self] day in
                self?.analyticsService.setUserProperty("current_day", value: day)
            }
            .store(in: &cancellables)
        
        userManager.$currentStreak
            .sink { [weak self] streak in
                self?.analyticsService.setUserProperty("current_streak", value: streak)
            }
            .store(in: &cancellables)
    }
    
    private func scheduleDefaultNotifications() {
        // Schedule daily activity reminder
        notificationService.scheduleActivityReminder()
        
        // Schedule weekly community update
        notificationService.scheduleCommunityUpdate()
        
        // Schedule weather alerts (if location is enabled)
        if locationService.isLocationEnabled {
            notificationService.scheduleWeatherAlert()
        }
    }
}

// MARK: - App State
enum AppState {
    case launching
    case initializing
    case ready
    case loggedOut
    case error
}

// MARK: - App Configuration
struct AppConfiguration {
    static let shared = AppConfiguration()
    
    let appName = "Breez"
    let appVersion = "1.0.0"
    let buildNumber = "1"
    let apiBaseURL = "https://api.breez.app"
    let supportEmail = "support@breez.app"
    let privacyPolicyURL = "https://breez.app/privacy"
    let termsOfServiceURL = "https://breez.app/terms"
    
    // Feature flags
    let isAnalyticsEnabled = true
    let isLocationEnabled = true
    let isNotificationsEnabled = true
    let isOfflineModeEnabled = true
    
    // App limits
    let maxImageSize = 10 * 1024 * 1024 // 10MB
    let maxReportImages = 5
    let maxActivityHistory = 100
    let maxBookmarks = 50
    
    private init() {}
}

// MARK: - App Constants
struct AppConstants {
    // Colors
    static let primaryColor = Color(hex: "3282B8")
    static let secondaryColor = Color(hex: "0F4C75")
    static let accentColor = Color(hex: "BBE1FA")
    
    // Spacing
    static let defaultPadding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    
    // Animation
    static let defaultAnimationDuration: Double = 0.3
    static let fastAnimationDuration: Double = 0.15
    static let slowAnimationDuration: Double = 0.6
    
    // Network
    static let requestTimeout: TimeInterval = 30
    static let maxRetryAttempts = 3
    
    // Location
    static let locationUpdateInterval: TimeInterval = 300 // 5 minutes
    static let locationAccuracy = kCLLocationAccuracyBest
    
    // Notifications
    static let maxPendingNotifications = 64
    static let notificationSoundEnabled = true
}

// MARK: - App Utilities
struct AppUtilities {
    static func getAppVersion() -> String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
    
    static func getDeviceInfo() -> String {
        let device = UIDevice.current
        return "\(device.model) - \(device.systemName) \(device.systemVersion)"
    }
    
    static func getAppSize() -> String {
        guard let bundlePath = Bundle.main.bundlePath as NSString? else {
            return "Unknown"
        }
        
        let fileManager = FileManager.default
        var folderSize: Int64 = 0
        
        if let enumerator = fileManager.enumerator(atPath: bundlePath as String) {
            while let file = enumerator.nextObject() as? String {
                let filePath = bundlePath.appendingPathComponent(file)
                if let attributes = try? fileManager.attributesOfItem(atPath: filePath),
                   let fileSize = attributes[.size] as? Int64 {
                    folderSize += fileSize
                }
            }
        }
        
        return ByteCountFormatter.string(fromByteCount: folderSize, countStyle: .file)
    }
    
    static func isFirstLaunch() -> Bool {
        return !UserDefaults.standard.bool(forKey: "has_launched_before")
    }
    
    static func setFirstLaunchCompleted() {
        UserDefaults.standard.set(true, forKey: "has_launched_before")
    }
    
    static func getLaunchCount() -> Int {
        return UserDefaults.standard.integer(forKey: "launch_count")
    }
    
    static func incrementLaunchCount() {
        let count = getLaunchCount() + 1
        UserDefaults.standard.set(count, forKey: "launch_count")
    }
}
