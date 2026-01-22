import Foundation
import SwiftUI
import Combine

@MainActor

class UserProfileViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authService = AuthService.shared
    private let dataService = DataService.shared
    
    init() {
        checkUserSession()
    }
    
    func checkUserSession() {
        if let uid = authService.getCurrentUserID() {
            isLoading = true
            Task {
                do {
                    self.currentUser = try await dataService.fetchUser(uid: uid)
                } catch {
                    print("Error fetching user: \(error)")
                }
                isLoading = false
            }
        }
    }
    
    func register(name: String, email: String, password: String, phoneNumber: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Create Auth User
            try await authService.signUp(email: email, password: password)
            
            guard let uid = authService.getCurrentUserID() else { return false }
            
            // 2. Create Firestore User
            let newUser = User(
                id: UUID(uuidString: uid) ?? UUID(),
                name: name,
                email: email,
                phoneNumber: phoneNumber,
                joinDate: Date(),
                role: .customer
            )
            
            try dataService.saveUser(newUser)
            self.currentUser = newUser
            isLoading = false
            return true
            
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    func login(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.signIn(email: email, password: password)
            
            if let uid = authService.getCurrentUserID() {
                self.currentUser = try await dataService.fetchUser(uid: uid)
            }
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
    
    // Legacy support for View compatibility - will be deprecated
    func createProfile(name: String, email: String, phoneNumber: String) {
        // This is kept for compatibility with existing views that don't pass password
        // In a real app, we should enforce password usage
        Task {
            _ = await register(name: name, email: email, password: "DefaultPassword123!", phoneNumber: phoneNumber)
        }
    }
    
    func updateProfile(name: String?, email: String?, phoneNumber: String?) {
        guard var user = currentUser else { return }
        
        if let name = name { user.name = name }
        if let email = email { user.email = email }
        if let phoneNumber = phoneNumber { user.phoneNumber = phoneNumber }
        
        saveUserToFirestore(user)
    }
    
    func updateProfileImage(imageData: Data?) {
        guard var user = currentUser else { return }
        user.profileImageData = imageData
        saveUserToFirestore(user)
    }
    
    func updatePreferences(_ preferences: UserPreferences) {
        guard var user = currentUser else { return }
        user.preferences = preferences
        saveUserToFirestore(user)
    }
    
    private func saveUserToFirestore(_ user: User) {
        self.currentUser = user
        Task {
            try? dataService.saveUser(user)
        }
    }
    
    func hasProfile() -> Bool {
        return currentUser != nil
    }
    
    func logout() {
        authService.signOut()
        currentUser = nil
    }
    
    // MARK: - Seed Demo Users
    /// Firebase'e 5 demo müşteri hesabı oluşturur
    /// Bu fonksiyon sadece bir kez çağrılmalıdır
    func seedDemoUsers() async {
        let demoUsers: [(name: String, email: String, password: String, phone: String)] = [
            ("Ahmet Yılmaz", "ahmet@ustn.com", "123456", "0532 111 2233"),
            ("Ayşe Demir", "ayse@ustn.com", "123456", "0533 222 3344"),
            ("Mehmet Kaya", "mehmet@ustn.com", "123456", "0534 333 4455"),
            ("Fatma Şahin", "fatma@ustn.com", "123456", "0535 444 5566"),
            ("Ali Öztürk", "ali@ustn.com", "123456", "0536 555 6677")
        ]
        
        for user in demoUsers {
            do {
                // Firebase Auth'a kaydet
                try await authService.signUp(email: user.email, password: user.password)
                
                if let uid = authService.getCurrentUserID() {
                    // Firestore'a kullanıcı bilgilerini kaydet
                    let newUser = User(
                        id: UUID(uuidString: uid) ?? UUID(),
                        name: user.name,
                        email: user.email,
                        phoneNumber: user.phone,
                        role: .customer
                    )
                    try dataService.saveUser(newUser)
                    print("✅ Kullanıcı oluşturuldu: \(user.email)")
                }
                
                // Sonraki kullanıcı için çıkış yap
                authService.signOut()
                
            } catch {
                print("❌ Kullanıcı oluşturulamadı: \(user.email) - \(error.localizedDescription)")
            }
        }
        
        print("🎉 Demo kullanıcıları seed işlemi tamamlandı!")
    }
}

