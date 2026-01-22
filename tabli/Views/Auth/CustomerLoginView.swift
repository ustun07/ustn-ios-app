import SwiftUI

struct CustomerLoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var showError = false
    @State private var isLoggedIn = false
    
    // Demo müşteri bilgileri
    private let demoUsername = "musteri"
    private let demoPassword = "1234"
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 40)
                        
                        // Header
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.brownMedium.opacity(0.3), AppTheme.brownDark.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(AppTheme.brownDark)
                            }
                            
                            Text("Müşteri Girişi")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text("Hesabınıza giriş yaparak siparişlerinizi takip edin")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        
                        // Form
                        VStack(spacing: 20) {
                            // Username Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("E-posta Adresi")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(AppTheme.brownMedium)
                                
                                HStack(spacing: 16) {
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.brownMedium)
                                        .frame(width: 24)
                                    
                                    TextField("E-posta adresinizi girin", text: $username)
                                        .font(.system(size: 17, design: .rounded))
                                        .autocapitalization(.none)
                                        .disableAutocorrection(true)
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            
                            // Password Field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Şifre")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(AppTheme.brownMedium)
                                
                                HStack(spacing: 16) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(AppTheme.brownMedium)
                                        .frame(width: 24)
                                    
                                    SecureField("Şifrenizi girin", text: $password)
                                        .font(.system(size: 17, design: .rounded))
                                }
                                .padding(18)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                            
                            if showError {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text("Kullanıcı adı veya şifre hatalı!")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.red)
                                }
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Login Button
                        Button(action: login) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 22))
                                
                                Text("Giriş Yap")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(20)
                            .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .padding(.top, 12)
                        
                        Spacer()
                            .frame(height: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Geri")
                        }
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    }
                }
            }
            .onChange(of: isLoggedIn) { newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
    
    private func login() {
        withAnimation {
            showError = false
        }
        
        // Real Firebase Login
        Task {
            let success = await profileViewModel.login(email: username, password: password)
            if success {
                isLoggedIn = true
            } else {
                withAnimation(.spring()) {
                    showError = true
                }
            }
        }
    }
}

#Preview {
    CustomerLoginView()
        .environmentObject(UserProfileViewModel())
}
