import Foundation
import SwiftUI
import Combine

@MainActor
class OrderViewModel: ObservableObject {
    @Published var orderItems: [OrderItem] = []
    @Published var currentTable: Table?
    @Published var orderStatus: OrderStatus = .none
    @Published var menuItems: [MenuItem] = MenuItem.sampleMenu
    @Published var favoriteItems: [MenuItem] = []
    @Published var orderHistory: [OrderHistoryItem] = []
    @Published var specialNotes: String = ""
    @Published var isLoading = false
    
    private let dataService = DataService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var totalPrice: Double {
        orderItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var itemCount: Int {
        orderItems.reduce(0) { $0 + $1.quantity }
    }
    
    func addItem(_ menuItem: MenuItem) {
        if let existingIndex = orderItems.firstIndex(where: { $0.menuItem.id == menuItem.id }) {
            orderItems[existingIndex].quantity += 1
        } else {
            orderItems.append(OrderItem(menuItem: menuItem, quantity: 1))
        }
    }
    
    func removeItem(_ orderItem: OrderItem) {
        if let index = orderItems.firstIndex(where: { $0.id == orderItem.id }) {
            if orderItems[index].quantity > 1 {
                orderItems[index].quantity -= 1
            } else {
                orderItems.remove(at: index)
            }
        }
    }
    
    func deleteItem(_ orderItem: OrderItem) {
        orderItems.removeAll { $0.id == orderItem.id }
    }
    
    func updatePortionSize(for orderItem: OrderItem, to size: PortionSize) {
        if let index = orderItems.firstIndex(where: { $0.id == orderItem.id }) {
            orderItems[index].portionSize = size
        }
    }
    
    func clearCart() {
        orderItems.removeAll()
    }
    
    // MARK: - Place Order (Firebase)
    func placeOrder() {
        guard !orderItems.isEmpty, let table = currentTable else { return }
        
        orderStatus = .pending
        
        let historyItem = OrderHistoryItem(
            id: UUID(),
            items: orderItems,
            table: table,
            totalPrice: totalPrice,
            date: Date(),
            notes: specialNotes
        )
        
        // Save to Firebase
        do {
            try dataService.placeOrder(historyItem)
            orderHistory.insert(historyItem, at: 0)
            specialNotes = ""
            
            // Bildirim gönder - sipariş alındı
            NotificationService.shared.sendOrderStatusNotification(
                orderNumber: "\(table.number)",
                status: "Siparişiniz alındı, onay bekleniyor."
            )
        } catch {
            print("Firebase order error: \(error.localizedDescription)")
            // Fallback to local
            orderHistory.insert(historyItem, at: 0)
            saveOrderHistoryLocal()
        }
    }
    
    // MARK: - Admin Functions
    func approveOrder() {
        guard orderStatus == .pending else { return }
        orderStatus = .preparing
        
        // Bildirim gönder
        NotificationService.shared.sendOrderStatusNotification(
            orderNumber: currentTable?.number.description ?? "1",
            status: "Siparişiniz onaylandı, hazırlanıyor!"
        )
    }
    
    func completeOrder() {
        guard orderStatus == .preparing else { return }
        orderStatus = .ready
        
        // Bildirim gönder
        if let table = currentTable {
            NotificationService.shared.sendOrderReadyNotification(tableNumber: "\(table.number)")
        } else {
            NotificationService.shared.sendOrderStatusNotification(
                orderNumber: "1",
                status: "Siparişiniz hazır!"
            )
        }
    }
    
    var statusDescription: String {
        switch orderStatus {
        case .none:
            return ""
        case .pending:
            return "Siparişiniz alındı, onay bekleniyor."
        case .preparing:
            return "Siparişiniz onaylandı, hazırlanıyor."
        case .ready:
            return "Siparişiniz hazır, afiyet olsun!"
        case .completed:
            return "Siparişiniz tamamlandı."
        }
    }
    
    func getMenuItems(for category: MenuCategory) -> [MenuItem] {
        menuItems.filter { $0.category == category }
    }
    
    // MARK: - Favorites
    func toggleFavorite(_ menuItem: MenuItem) {
        if favoriteItems.contains(where: { $0.id == menuItem.id }) {
            favoriteItems.removeAll { $0.id == menuItem.id }
        } else {
            favoriteItems.append(menuItem)
        }
        saveFavorites()
    }
    
    func isFavorite(_ menuItem: MenuItem) -> Bool {
        favoriteItems.contains(where: { $0.id == menuItem.id })
    }
    
    private func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favoriteItems.map { $0.id.uuidString }) {
            UserDefaults.standard.set(encoded, forKey: "favoriteItems")
        }
    }
    
    private func loadFavorites() {
        guard let data = UserDefaults.standard.data(forKey: "favoriteItems"),
              let favoriteIds = try? JSONDecoder().decode([String].self, from: data) else { return }
        
        favoriteItems = menuItems.filter { item in
            favoriteIds.contains(item.id.uuidString)
        }
    }
    
    // MARK: - Order History (Firebase)
    func loadOrderHistory() {
        isLoading = true
        Task {
            do {
                let orders = try await dataService.fetchOrders()
                await MainActor.run {
                    self.orderHistory = orders
                    self.isLoading = false
                }
            } catch {
                print("Firebase fetch orders error: \(error.localizedDescription)")
                // Fallback to local
                loadOrderHistoryLocal()
                isLoading = false
            }
        }
    }
    
    private func saveOrderHistoryLocal() {
        if let encoded = try? JSONEncoder().encode(orderHistory) {
            UserDefaults.standard.set(encoded, forKey: "orderHistory")
        }
    }
    
    private func loadOrderHistoryLocal() {
        guard let data = UserDefaults.standard.data(forKey: "orderHistory"),
              let history = try? JSONDecoder().decode([OrderHistoryItem].self, from: data) else { return }
        orderHistory = history
    }
    
    // MARK: - QR Code
    func setTableFromQR(code: String) {
        let tableNumber = code
            .replacingOccurrences(of: "table-", with: "", options: .caseInsensitive)
            .trimmingCharacters(in: .whitespaces)
        
        if let number = Int(tableNumber),
           let table = Table.availableTables.first(where: { $0.number == number }) {
            currentTable = table
        }
    }
    
    init() {
        loadFavorites()
        loadOrderHistory()
    }
}
