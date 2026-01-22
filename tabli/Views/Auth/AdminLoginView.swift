import SwiftUI

struct AdminLoginView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var isLoggedIn = false
    @State private var errorMessage = ""
    
    // Sabit admin emaili
    private let adminEmail = "admin@ustn.com"
    private let fallbackPassword = "admin123"
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownMedium.opacity(0.3), AppTheme.brownDark.opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Image(systemName: "person.badge.key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(AppTheme.brownDark)
                    }
                    
                    Text("Yönetici Girişi")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    // Form
                    VStack(spacing: 20) {
                        // Email Field
                        HStack(spacing: 16) {
                            Image(systemName: "envelope.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.brownMedium)
                                .frame(width: 24)
                            
                            TextField("E-posta (admin@ustn.com)", text: $email)
                                .font(.system(size: 17, design: .rounded))
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .keyboardType(.emailAddress)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                        )
                        
                        // Password Field
                        HStack(spacing: 16) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(AppTheme.brownMedium)
                                .frame(width: 24)
                            
                            SecureField("Şifre", text: $password)
                                .font(.system(size: 17, design: .rounded))
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                        )
                        
                        if showError {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .transition(.opacity)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Login Button
                    Button(action: login) {
                        if profileViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 22))
                                
                                Text("Giriş Yap")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
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
                    .disabled(profileViewModel.isLoading)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    
                    Spacer()
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
            }
            .fullScreenCover(isPresented: $isLoggedIn) {
                AdminDashboardView()
            }
        }
    }
    
    private func login() {
        withAnimation {
            showError = false
        }
        
        // 1. Hardcoded backup
        if email == adminEmail && password == fallbackPassword {
            isLoggedIn = true
            return
        }
        
        // 2. Firebase Verification
        Task {
            let success = await profileViewModel.login(email: email, password: password)
            if success {
                if email.lowercased() == adminEmail.lowercased() {
                    isLoggedIn = true
                } else {
                    errorMessage = "Bu hesabın yönetici yetkisi yok."
                    withAnimation { showError = true }
                    profileViewModel.logout()
                }
            } else {
                errorMessage = profileViewModel.errorMessage ?? "Giriş başarısız."
                withAnimation { showError = true }
            }
        }
    }
}

#Preview {
    AdminLoginView()
        .environmentObject(UserProfileViewModel())
}
