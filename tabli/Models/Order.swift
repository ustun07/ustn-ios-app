import Foundation

struct OrderHistoryItem: Identifiable, Codable {
    let id: UUID
    let items: [OrderItem]
    let table: Table
    let totalPrice: Double
    let date: Date
    let notes: String
}

enum OrderStatus: String, Codable {
    case none = "None"
    case pending = "Pending"
    case preparing = "Preparing"
    case ready = "Ready"
    case completed = "Completed"
}
