import SwiftUI
import FirebaseCore
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = NotificationService.shared
        
        // Apply saved theme
        ThemeManager.shared.applyTheme()
        
        return true
    }
}

@main
struct tabliApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var localizationManager: LocalizationManager
    @StateObject private var profileViewModel = UserProfileViewModel()
    @StateObject private var orderViewModel = OrderViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        let manager = LocalizationManager.shared
        _localizationManager = StateObject(wrappedValue: manager)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(localizationManager)
                .environmentObject(profileViewModel)
                .environmentObject(orderViewModel)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

