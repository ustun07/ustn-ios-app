import Foundation
import FirebaseFirestore

import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    private let db = Firestore.firestore()
    
    // MARK: - Menu Items
    func fetchMenuItems() async throws -> [MenuItem] {
        let snapshot = try await db.collection("menuItems").getDocuments()
        return snapshot.documents.compactMap { document in
            try? document.data(as: MenuItem.self)
        }
    }
    
    func addMenuItem(_ item: MenuItem) throws {
        try db.collection("menuItems").document(item.id.uuidString).setData(from: item)
    }
    
    // MARK: - Orders
    func fetchOrders() async throws -> [OrderHistoryItem] {
        let snapshot = try await db.collection("orders")
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: OrderHistoryItem.self)
        }
    }
    
    func placeOrder(_ order: OrderHistoryItem) throws {
        try db.collection("orders").document(order.id.uuidString).setData(from: order)
    }
    
    func updateOrderStatus(orderId: String, status: String) async throws {
        try await db.collection("orders").document(orderId).updateData([
            "status": status
        ])
    }
    
    // MARK: - Users
    func fetchUser(uid: String) async throws -> User? {
        let document = try await db.collection("users").document(uid).getDocument()
        return try? document.data(as: User.self)
    }
    
    func saveUser(_ user: User) throws {
        // Use ID as string for document ID
        try db.collection("users").document(user.id.uuidString).setData(from: user)
    }
    
    // MARK: - Real-time Listeners
    func listenToOrders() -> AnyPublisher<[OrderHistoryItem], Error> {
        let subject = PassthroughSubject<[OrderHistoryItem], Error>()
        
        db.collection("orders")
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    subject.send(completion: .failure(error))
                    return
                }
                
                guard let snapshot = snapshot else { return }
                
                let orders = snapshot.documents.compactMap { document in
                    try? document.data(as: OrderHistoryItem.self)
                }
                
                subject.send(orders)
            }
            
        return subject.eraseToAnyPublisher()
    }
}
