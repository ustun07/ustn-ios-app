import SwiftUI

struct AuthMenuView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var showCustomerLogin = false
    @State private var showAdminLogin = false
    @State private var showRegister = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Spacer()
                    
                    // Logo
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.brownMedium.opacity(0.3),
                                        AppTheme.brownDark.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 180, height: 180)
                        
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 280, height: 280)
                    }
                    
                    Text("Hoş Geldiniz")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("Devam etmek için bir seçenek seçin")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                    
                    Spacer()
                    
                    // Buttons
                    VStack(spacing: 16) {
                        // Customer Login Button
                        Button(action: {
                            showCustomerLogin = true
                        }) {
                            AuthMenuButton(
                                icon: "person.fill",
                                title: "Müşteri Girişi",
                                subtitle: "Hesabınıza giriş yapın",
                                isPrimary: true
                            )
                        }
                        
                        // Admin Login Button
                        Button(action: {
                            showAdminLogin = true
                        }) {
                            AuthMenuButton(
                                icon: "person.badge.key.fill",
                                title: "Yönetici Girişi",
                                subtitle: "Yönetici paneline erişin",
                                isPrimary: false
                            )
                        }
                        
                        // Register Button
                        Button(action: {
                            showRegister = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18))
                                Text("Kayıt Ol")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.brownDark)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppTheme.brownMedium.opacity(0.5), lineWidth: 2)
                            )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
            }
            .sheet(isPresented: $showCustomerLogin, onDismiss: {
                // Check if user is logged in after CustomerLoginView dismisses
                // Use delay to prevent race condition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if profileViewModel.currentUser != nil {
                        dismiss()
                    }
                }
            }) {
                CustomerLoginView()
                    .environmentObject(profileViewModel)
            }
            .sheet(isPresented: $showAdminLogin) {
                AdminLoginView()
                    .environmentObject(profileViewModel)
            }
            .sheet(isPresented: $showRegister, onDismiss: {
                // Check if user is registered after RegisterView dismisses
                // Use delay to prevent race condition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    if profileViewModel.currentUser != nil {
                        dismiss()
                    }
                }
            }) {
                RegisterView()
                    .environmentObject(profileViewModel)
            }
        }
    }
}

// MARK: - Auth Menu Button
struct AuthMenuButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let isPrimary: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        isPrimary ?
                        LinearGradient(
                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [AppTheme.brownMedium.opacity(0.3), AppTheme.brownMedium.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isPrimary ? .white : AppTheme.brownDark)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isPrimary ? .white : AppTheme.brownDark)
                
                Text(subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(isPrimary ? .white.opacity(0.8) : AppTheme.brownMedium)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isPrimary ? .white.opacity(0.7) : AppTheme.brownMedium)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    isPrimary ?
                    LinearGradient(
                        colors: [AppTheme.brownDark, AppTheme.brownMedium],
                        startPoint: .leading,
                        endPoint: .trailing
                    ) :
                    LinearGradient(
                        colors: [Color.white.opacity(0.001), Color.white.opacity(0.001)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: isPrimary ? AppTheme.brownDark.opacity(0.4) : Color.clear, radius: 15, x: 0, y: 8)
        )
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .opacity(isPrimary ? 0 : 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isPrimary ?
                    Color.white.opacity(0.2) :
                    AppTheme.brownMedium.opacity(0.3),
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    AuthMenuView()
}
