import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isRegistered = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        Spacer()
                            .frame(height: 20)
                        
                        // Header
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.brownMedium.opacity(0.3), AppTheme.brownDark.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 90, height: 90)
                                
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppTheme.brownDark)
                            }
                            
                            Text("Kayıt Ol")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text("Yeni bir hesap oluşturun")
                                .font(.system(size: 15, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                        
                        // Form
                        VStack(spacing: 16) {
                            RegisterTextField(
                                icon: "person.fill",
                                title: "Ad Soyad",
                                placeholder: "Adınızı girin",
                                text: $name
                            )
                            
                            RegisterTextField(
                                icon: "at",
                                title: "Kullanıcı Adı",
                                placeholder: "Kullanıcı adı seçin",
                                text: $username
                            )
                            
                            RegisterTextField(
                                icon: "envelope.fill",
                                title: "E-posta",
                                placeholder: "E-posta adresiniz",
                                text: $email,
                                keyboardType: .emailAddress
                            )
                            
                            RegisterTextField(
                                icon: "phone.fill",
                                title: "Telefon (İsteğe Bağlı)",
                                placeholder: "Telefon numaranız",
                                text: $phone,
                                keyboardType: .phonePad
                            )
                            
                            RegisterSecureField(
                                icon: "lock.fill",
                                title: "Şifre",
                                placeholder: "Şifrenizi girin",
                                text: $password
                            )
                            
                            RegisterSecureField(
                                icon: "lock.shield.fill",
                                title: "Şifre Tekrar",
                                placeholder: "Şifrenizi tekrar girin",
                                text: $confirmPassword
                            )
                            
                            if showError {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(errorMessage)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.red)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.red.opacity(0.1))
                                )
                                .transition(.opacity.combined(with: .scale))
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        // Register Button
                        Button(action: register) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                
                                Text("Kayıt Ol")
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
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        
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
            .onChange(of: isRegistered) { newValue in
                if newValue {
                    dismiss()
                }
            }
        }
    }
    
    private func register() {
        withAnimation {
            showError = false
        }
        
        // Validation
        if name.isEmpty {
            showErrorWith("Lütfen adınızı girin")
            return
        }
        
        if username.isEmpty {
            showErrorWith("Lütfen kullanıcı adı seçin")
            return
        }
        
        if email.isEmpty {
            showErrorWith("Lütfen e-posta adresinizi girin")
            return
        }
        
        if password.isEmpty {
            showErrorWith("Lütfen şifre girin")
            return
        }
        
        if password != confirmPassword {
            showErrorWith("Şifreler eşleşmiyor")
            return
        }
        
        if password.count < 4 {
            showErrorWith("Şifre en az 4 karakter olmalı")
            return
        }
        
        // Create profile
        // Create profile in Firebase
        Task {
            let success = await profileViewModel.register(
                name: name,
                email: email,
                password: password,
                phoneNumber: phone
            )
            
            if success {
                isRegistered = true
            } else {
                showErrorWith(profileViewModel.errorMessage ?? "Kayıt olurken bir hata oluştu.")
            }
        }
    }
    
    private func showErrorWith(_ message: String) {
        errorMessage = message
        withAnimation(.spring()) {
            showError = true
        }
    }
}

// MARK: - Register Text Field
struct RegisterTextField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
            
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.brownMedium)
                    .frame(width: 22)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, design: .rounded))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(keyboardType)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.brownMedium.opacity(0.25), lineWidth: 1.5)
            )
        }
    }
}

// MARK: - Register Secure Field
struct RegisterSecureField: View {
    let icon: String
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
            
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(AppTheme.brownMedium)
                    .frame(width: 22)
                
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, design: .rounded))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(AppTheme.brownMedium.opacity(0.25), lineWidth: 1.5)
            )
        }
    }
}

#Preview {
    RegisterView()
        .environmentObject(UserProfileViewModel())
}
