import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    @Published var user: User?
    var userSession: FirebaseAuth.User?
    
    static let shared = AuthService()
    
    init() {
        self.userSession = Auth.auth().currentUser
    }
    
    func signIn(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Login error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signUp(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
        } catch {
            print("Register error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.userSession = nil
        } catch {
            print("Sign out error: \(error.localizedDescription)")
        }
    }
    
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
}
