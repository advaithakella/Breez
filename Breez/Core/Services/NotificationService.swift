import Foundation
import UserNotifications
import Combine

// MARK: - Notification Service
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isEnabled = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override init() {
        super.init()
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { [weak self] granted, error in
            DispatchQueue.main.async {
                if granted {
                    self?.isEnabled = true
                    self?.checkAuthorizationStatus()
                } else {
                    self?.isEnabled = false
                }
            }
        }
    }
    
    private func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatus = settings.authorizationStatus
                self?.isEnabled = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Local Notifications
    func scheduleLocalNotification(
        id: String,
        title: String,
        body: String,
        timeInterval: TimeInterval,
        repeats: Bool = false
    ) {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func scheduleDailyReminder(
        id: String,
        title: String,
        body: String,
        hour: Int,
        minute: Int
    ) {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling daily reminder: \(error)")
            }
        }
    }
    
    func scheduleWeeklyReminder(
        id: String,
        title: String,
        body: String,
        weekday: Int,
        hour: Int,
        minute: Int
    ) {
        guard isEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.badge = 1
        
        var dateComponents = DateComponents()
        dateComponents.weekday = weekday
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling weekly reminder: \(error)")
            }
        }
    }
    
    // MARK: - Specific Notifications
    func scheduleActivityReminder() {
        scheduleDailyReminder(
            id: "activity_reminder",
            title: "Time for your daily activity! 🌱",
            body: "Don't forget to log your environmental impact today",
            hour: 18,
            minute: 0
        )
    }
    
    func scheduleChallengeReminder(challengeName: String) {
        scheduleLocalNotification(
            id: "challenge_reminder_\(challengeName)",
            title: "Challenge Update! 🏆",
            body: "Keep up the great work with \(challengeName)",
            timeInterval: 86400, // 24 hours
            repeats: true
        )
    }
    
    func scheduleReportFollowUp(reportId: String) {
        scheduleLocalNotification(
            id: "report_followup_\(reportId)",
            title: "Report Follow-up 📊",
            body: "Check the status of your environmental report",
            timeInterval: 604800, // 7 days
            repeats: false
        )
    }
    
    func scheduleCommunityUpdate() {
        scheduleWeeklyReminder(
            id: "community_update",
            title: "Community Highlights 🌊",
            body: "See what's happening in your environmental community",
            weekday: 1, // Monday
            hour: 9,
            minute: 0
        )
    }
    
    func scheduleWeatherAlert() {
        scheduleLocalNotification(
            id: "weather_alert",
            title: "Weather Alert ⚠️",
            body: "Check beach conditions before heading out",
            timeInterval: 3600, // 1 hour
            repeats: true
        )
    }
    
    // MARK: - Notification Management
    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func getPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] requests in
            DispatchQueue.main.async {
                self?.pendingNotifications = requests
            }
        }
    }
    
    func clearBadgeCount() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    // MARK: - Notification Categories
    func setupNotificationCategories() {
        let activityCategory = UNNotificationCategory(
            identifier: "ACTIVITY",
            actions: [
                UNNotificationAction(identifier: "LOG_ACTIVITY", title: "Log Activity", options: [.foreground]),
                UNNotificationAction(identifier: "REMIND_LATER", title: "Remind Later", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let challengeCategory = UNNotificationCategory(
            identifier: "CHALLENGE",
            actions: [
                UNNotificationAction(identifier: "VIEW_CHALLENGE", title: "View Challenge", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        let reportCategory = UNNotificationCategory(
            identifier: "REPORT",
            actions: [
                UNNotificationAction(identifier: "VIEW_REPORT", title: "View Report", options: [.foreground]),
                UNNotificationAction(identifier: "DISMISS", title: "Dismiss", options: [])
            ],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            activityCategory,
            challengeCategory,
            reportCategory
        ])
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "LOG_ACTIVITY":
            // Handle log activity action
            NotificationCenter.default.post(name: .logActivity, object: nil)
        case "VIEW_CHALLENGE":
            // Handle view challenge action
            NotificationCenter.default.post(name: .viewChallenge, object: userInfo)
        case "VIEW_REPORT":
            // Handle view report action
            NotificationCenter.default.post(name: .viewReport, object: userInfo)
        case "REMIND_LATER":
            // Handle remind later action
            scheduleLocalNotification(
                id: "activity_reminder_later",
                title: "Activity Reminder 🌱",
                body: "Don't forget to log your environmental impact",
                timeInterval: 3600, // 1 hour
                repeats: false
            )
        default:
            break
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let logActivity = Notification.Name("logActivity")
    static let viewChallenge = Notification.Name("viewChallenge")
    static let viewReport = Notification.Name("viewReport")
}
