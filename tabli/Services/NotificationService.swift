import Foundation
import Combine
import UserNotifications

/// Service for managing local push notifications
class NotificationService: NSObject, ObservableObject {
    static let shared = NotificationService()
    
    @Published var isNotificationsEnabled: Bool = false
    
    private override init() {
        super.init()
    }
    
    // MARK: - Permission Request
    
    /// Request notification permissions from the user
    func requestPermission(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = granted
                if let error = error {
                    print("Notification permission error: \(error.localizedDescription)")
                }
                completion(granted)
            }
        }
    }
    
    /// Check current notification permission status
    func checkPermissionStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isNotificationsEnabled = settings.authorizationStatus == .authorized
                completion(settings.authorizationStatus)
            }
        }
    }
    
    // MARK: - Local Notifications
    
    /// Schedule a local notification for order status updates
    func sendOrderStatusNotification(orderNumber: String, status: String) {
        let content = UNMutableNotificationContent()
        content.title = "Sipariş Durumu Güncellendi"
        content.body = "Sipariş #\(orderNumber) - \(status)"
        content.sound = .default
        content.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Local notification error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Send notification when order is ready
    func sendOrderReadyNotification(tableNumber: String) {
        let content = UNMutableNotificationContent()
        content.title = "Siparişiniz Hazır! 🎉"
        content.body = "Masa \(tableNumber) - Siparişiniz hazır ve bekliyor."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "order_ready_\(tableNumber)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Send a test notification
    func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Bildirimi"
        content.body = "Bildirimler düzgün çalışıyor!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(
            identifier: "test_notification",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Badge Management
    
    /// Clear notification badge
    func clearBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
        
        // Also trigger in-app banner
        let content = notification.request.content
        NotificationCenter.default.post(
            name: .inAppNotification,
            object: nil,
            userInfo: ["title": content.title, "message": content.body]
        )
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification tap
        let userInfo = response.notification.request.content.userInfo
        print("Notification tapped with info: \(userInfo)")
        completionHandler()
    }
}

extension Notification.Name {
    static let inAppNotification = Notification.Name("InAppNotification")
}
