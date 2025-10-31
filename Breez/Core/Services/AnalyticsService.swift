import Foundation
import Combine

// MARK: - Analytics Service
class AnalyticsService: ObservableObject {
    static let shared = AnalyticsService()
    
    @Published var isEnabled = true
    @Published var userConsent = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        loadUserConsent()
    }
    
    // MARK: - Event Tracking
    func trackEvent(_ event: AnalyticsEvent) {
        guard isEnabled && userConsent else { return }
        
        // In a real app, you would send this to your analytics provider
        print("📊 Analytics Event: \(event.name)")
        print("📊 Properties: \(event.properties)")
        
        // Store locally for debugging
        storeEventLocally(event)
    }
    
    func trackScreenView(_ screenName: String, properties: [String: Any] = [:]) {
        let event = AnalyticsEvent(
            name: "screen_view",
            properties: [
                "screen_name": screenName,
                "timestamp": Date().timeIntervalSince1970
            ].merging(properties) { _, new in new }
        )
        trackEvent(event)
    }
    
    func trackUserAction(_ action: String, properties: [String: Any] = [:]) {
        let event = AnalyticsEvent(
            name: "user_action",
            properties: [
                "action": action,
                "timestamp": Date().timeIntervalSince1970
            ].merging(properties) { _, new in new }
        )
        trackEvent(event)
    }
    
    func trackReportCreated(_ reportType: String, location: String) {
        let event = AnalyticsEvent(
            name: "report_created",
            properties: [
                "report_type": reportType,
                "location": location,
                "timestamp": Date().timeIntervalSince1970
            ]
        )
        trackEvent(event)
    }
    
    func trackActivityCompleted(_ activityType: String, impact: EnvironmentalImpact) {
        let event = AnalyticsEvent(
            name: "activity_completed",
            properties: [
                "activity_type": activityType,
                "carbon_saved": impact.carbonSaved,
                "plastic_avoided": impact.plasticAvoided,
                "water_saved": impact.waterSaved,
                "timestamp": Date().timeIntervalSince1970
            ]
        )
        trackEvent(event)
    }
    
    func trackChallengeJoined(_ challengeId: String, challengeType: String) {
        let event = AnalyticsEvent(
            name: "challenge_joined",
            properties: [
                "challenge_id": challengeId,
                "challenge_type": challengeType,
                "timestamp": Date().timeIntervalSince1970
            ]
        )
        trackEvent(event)
    }
    
    func trackCommunityInteraction(_ interactionType: String, targetId: String) {
        let event = AnalyticsEvent(
            name: "community_interaction",
            properties: [
                "interaction_type": interactionType,
                "target_id": targetId,
                "timestamp": Date().timeIntervalSince1970
            ]
        )
        trackEvent(event)
    }
    
    // MARK: - User Properties
    func setUserProperty(_ key: String, value: Any) {
        guard isEnabled && userConsent else { return }
        
        // In a real app, you would set this in your analytics provider
        print("📊 User Property: \(key) = \(value)")
    }
    
    func setUserId(_ userId: String) {
        guard isEnabled && userConsent else { return }
        
        // In a real app, you would set this in your analytics provider
        print("📊 User ID: \(userId)")
    }
    
    // MARK: - Consent Management
    func requestUserConsent() {
        // In a real app, you would show a consent dialog
        userConsent = true
        saveUserConsent()
    }
    
    func revokeUserConsent() {
        userConsent = false
        saveUserConsent()
    }
    
    private func loadUserConsent() {
        userConsent = UserDefaults.standard.bool(forKey: "analytics_consent")
    }
    
    private func saveUserConsent() {
        UserDefaults.standard.set(userConsent, forKey: "analytics_consent")
    }
    
    // MARK: - Local Storage
    private func storeEventLocally(_ event: AnalyticsEvent) {
        // Store events locally for debugging/offline support
        var events = UserDefaults.standard.array(forKey: "analytics_events") as? [[String: Any]] ?? []
        
        let eventDict: [String: Any] = [
            "name": event.name,
            "properties": event.properties,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        events.append(eventDict)
        
        // Keep only last 100 events
        if events.count > 100 {
            events = Array(events.suffix(100))
        }
        
        UserDefaults.standard.set(events, forKey: "analytics_events")
    }
    
    func getStoredEvents() -> [[String: Any]] {
        return UserDefaults.standard.array(forKey: "analytics_events") as? [[String: Any]] ?? []
    }
    
    func clearStoredEvents() {
        UserDefaults.standard.removeObject(forKey: "analytics_events")
    }
}

// MARK: - Analytics Event
struct AnalyticsEvent {
    let name: String
    let properties: [String: Any]
}

// MARK: - Predefined Events
extension AnalyticsService {
    // App Events
    func trackAppLaunch() {
        trackEvent(AnalyticsEvent(name: "app_launch", properties: [:]))
    }
    
    func trackAppBackground() {
        trackEvent(AnalyticsEvent(name: "app_background", properties: [:]))
    }
    
    func trackAppForeground() {
        trackEvent(AnalyticsEvent(name: "app_foreground", properties: [:]))
    }
    
    // Onboarding Events
    func trackOnboardingStarted() {
        trackEvent(AnalyticsEvent(name: "onboarding_started", properties: [:]))
    }
    
    func trackOnboardingCompleted() {
        trackEvent(AnalyticsEvent(name: "onboarding_completed", properties: [:]))
    }
    
    func trackOnboardingStepCompleted(_ step: String) {
        trackEvent(AnalyticsEvent(name: "onboarding_step_completed", properties: ["step": step]))
    }
    
    // Feature Usage
    func trackFeatureUsed(_ feature: String) {
        trackEvent(AnalyticsEvent(name: "feature_used", properties: ["feature": feature]))
    }
    
    func trackSearchPerformed(_ query: String, resultsCount: Int) {
        trackEvent(AnalyticsEvent(name: "search_performed", properties: [
            "query": query,
            "results_count": resultsCount
        ]))
    }
    
    func trackFilterApplied(_ filterType: String, filterValue: String) {
        trackEvent(AnalyticsEvent(name: "filter_applied", properties: [
            "filter_type": filterType,
            "filter_value": filterValue
        ]))
    }
    
    // Error Tracking
    func trackError(_ error: Error, context: String) {
        trackEvent(AnalyticsEvent(name: "error_occurred", properties: [
            "error_description": error.localizedDescription,
            "context": context
        ]))
    }
    
    func trackCrash(_ crashInfo: [String: Any]) {
        trackEvent(AnalyticsEvent(name: "crash_occurred", properties: crashInfo))
    }
}
