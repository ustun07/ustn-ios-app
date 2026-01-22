import Foundation

enum UserRole: String, Codable, Equatable {
    case customer
    case admin
}

struct User: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var email: String
    var phoneNumber: String
    var profileImageData: Data?
    var joinDate: Date
    var preferences: UserPreferences
    var role: UserRole
    
    init(
        id: UUID = UUID(),
        name: String = "",
        email: String = "",
        phoneNumber: String = "",
        profileImageData: Data? = nil,
        joinDate: Date = Date(),
        preferences: UserPreferences = UserPreferences(),
        role: UserRole = .customer
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.phoneNumber = phoneNumber
        self.profileImageData = profileImageData
        self.joinDate = joinDate
        self.preferences = preferences
        self.role = role
    }
}

struct UserPreferences: Codable, Equatable {
    var favoriteCategories: [MenuCategory]
    var dietaryRestrictions: [String]
    var preferredLanguage: AppLanguage
    var notificationsEnabled: Bool
    var darkModeEnabled: Bool
    
    init(
        favoriteCategories: [MenuCategory] = [],
        dietaryRestrictions: [String] = [],
        preferredLanguage: AppLanguage = .turkish,
        notificationsEnabled: Bool = true,
        darkModeEnabled: Bool = false
    ) {
        self.favoriteCategories = favoriteCategories
        self.dietaryRestrictions = dietaryRestrictions
        self.preferredLanguage = preferredLanguage
        self.notificationsEnabled = notificationsEnabled
        self.darkModeEnabled = darkModeEnabled
    }
}

