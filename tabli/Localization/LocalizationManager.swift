import SwiftUI
import Foundation
import Combine

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case english = "en"
    case turkish = "tr"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
    
    var nativeName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        }
    }
}

class LocalizationManager: ObservableObject {
    @Published var currentLanguage: AppLanguage
    
    static let shared = LocalizationManager()
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        self.currentLanguage = AppLanguage(rawValue: savedLanguage) ?? .english
        Bundle.setLanguage(currentLanguage.rawValue)
    }
    
    func setLanguage(_ language: AppLanguage) {
        currentLanguage = language
        UserDefaults.standard.set(language.rawValue, forKey: "app_language")
        Bundle.setLanguage(language.rawValue)
    }
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return NSLocalizedString(key, comment: "")
        }
        return NSLocalizedString(key, bundle: bundle, comment: "")
    }
}

extension Bundle {
    private static var bundleKey: UInt8 = 0
    
    class func setLanguage(_ language: String) {

        UserDefaults.standard.set([language], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
    }
}

extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}
