import Foundation

enum MenuCategory: String, CaseIterable, Identifiable, Codable {
    case foods = "Foods"
    case drinks = "Drinks"
    case desserts = "Desserts"
    case extras = "Extras"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .foods: return "🍖"
        case .drinks: return "🥤"
        case .desserts: return "🍮"
        case .extras: return "🥗"
        }
    }
    
    var localizedName: String {
        switch self {
        case .foods: return LocalizationManager.shared.currentLanguage == .turkish ? "Yiyecekler" : "Foods"
        case .drinks: return LocalizationManager.shared.currentLanguage == .turkish ? "İçecekler" : "Drinks"
        case .desserts: return LocalizationManager.shared.currentLanguage == .turkish ? "Tatlılar" : "Desserts"
        case .extras: return LocalizationManager.shared.currentLanguage == .turkish ? "Ekstralar" : "Extras"
        }
    }
    
    // Sadece yiyecekler için porsiyon seçeneği var
    var hasPortionOption: Bool {
        return self == .foods
    }
}

// Porsiyon seçenekleri
enum PortionSize: String, CaseIterable, Identifiable, Codable {
    case normal = "Normal"
    case birBucuk = "1.5 Porsiyon"
    case duble = "Duble"
    
    var id: String { rawValue }
    
    var multiplier: Double {
        switch self {
        case .normal: return 1.0
        case .birBucuk: return 1.5
        case .duble: return 2.0
        }
    }
    
    var displayName: String {
        switch self {
        case .normal: return "Normal"
        case .birBucuk: return "1.5 Porsiyon"
        case .duble: return "Duble"
        }
    }
}

struct MenuItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let imageName: String
    let category: MenuCategory
    
    init(id: UUID = UUID(), name: String, description: String, price: Double, imageName: String, category: MenuCategory) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageName = imageName
        self.category = category
    }
}

struct OrderItem: Identifiable, Equatable, Codable {
    let id: UUID
    let menuItem: MenuItem
    var quantity: Int
    var portionSize: PortionSize
    
    var totalPrice: Double {
        menuItem.price * Double(quantity) * portionSize.multiplier
    }
    
    init(menuItem: MenuItem, quantity: Int = 1, portionSize: PortionSize = .normal) {
        self.id = UUID()
        self.menuItem = menuItem
        self.quantity = quantity
        self.portionSize = portionSize
    }
}

struct Table: Identifiable, Equatable, Codable {
    let id: Int
    let number: Int
    
    static let availableTables: [Table] = (1...20).map { Table(id: $0, number: $0) }
}
