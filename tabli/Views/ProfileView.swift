import SwiftUI
import UIKit

struct ProfileView: View {
    @ObservedObject var profileViewModel: UserProfileViewModel
    @ObservedObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showEditProfile = false
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showFavorites = false
    @State private var showOrderHistory = false
    @State private var showLanguagePicker = false
    @State private var showAbout = false
    @State private var showAdminLogin = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                // Floating orbs
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if let user = profileViewModel.currentUser {
                            ProfileHeaderView(
                                user: user,
                                orderViewModel: orderViewModel,
                                onEditImage: {
                                    showImagePicker = true
                                }
                            )
                            
                            ProfileStatsView(orderViewModel: orderViewModel)
                            
                            ProfileMenuView(
                                user: user,
                                profileViewModel: profileViewModel,
                                orderViewModel: orderViewModel,
                                onEditProfile: {
                                    showEditProfile = true
                                },
                                onShowFavorites: {
                                    showFavorites = true
                                },
                                onShowOrderHistory: {
                                    showOrderHistory = true
                                },
                                onShowLanguagePicker: {
                                    showLanguagePicker = true
                                },
                                onShowAbout: {
                                    showAbout = true
                                },
                                onShowAdminLogin: {
                                    showAdminLogin = true
                                },
                                onLogout: {
                                    profileViewModel.logout()
                                    dismiss()
                                }
                            )
                        } else {
                            EmptyProfileView {
                                showEditProfile = true
                            }
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("profile".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
            }
            .sheet(isPresented: $showEditProfile) {
                if let user = profileViewModel.currentUser {
                    EditProfileView(
                        user: user,
                        profileViewModel: profileViewModel
                    )
                } else {
                    CreateProfileView(profileViewModel: profileViewModel)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(selectedImage: $selectedImage) { image in
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        profileViewModel.updateProfileImage(imageData: imageData)
                    }
                }
            }
            .sheet(isPresented: $showFavorites) {
                FavoritesView(viewModel: orderViewModel)
            }
            .sheet(isPresented: $showOrderHistory) {
                OrderHistoryView(viewModel: orderViewModel)
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView()
            }
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showAdminLogin) {
                AdminLoginView()
                    .environmentObject(orderViewModel)
            }
        }
    }
}

struct ProfileHeaderView: View {
    let user: User
    let orderViewModel: OrderViewModel
    let onEditImage: () -> Void
    

    
    var body: some View {
        VStack(spacing: 20) {
            ZStack(alignment: .bottomTrailing) {
                if let imageData = user.profileImageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppTheme.brownMedium, lineWidth: 3))
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownMedium, AppTheme.brownDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                        
                        Text(user.name.prefix(1).uppercased())
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .overlay(Circle().stroke(AppTheme.brownMedium, lineWidth: 3))
                }
                
                Button(action: onEditImage) {
                    ZStack {
                        Circle()
                            .fill(AppTheme.cardBackground)
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "camera.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppTheme.brownDark)
                    }
                    .shadow(color: AppTheme.brownDark.opacity(0.2), radius: 8, x: 0, y: 4)
                }
            }
            
            VStack(spacing: 8) {
                        Text(user.name.isEmpty ? "profile".localized : user.name)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                if !user.email.isEmpty {
                    Text(user.email)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                
                if !user.phoneNumber.isEmpty {
                    Text(user.phoneNumber)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                

            }
        }
        .padding(.vertical, 20)
    }
}

struct ProfileStatsView: View {
    @ObservedObject var orderViewModel: OrderViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            StatCard(
                icon: "star.fill",
                value: "\(orderViewModel.favoriteItems.count)",
                label: LocalizationManager.shared.currentLanguage == .turkish ? "Favoriler" : "Favorites"
            )
            
            StatCard(
                icon: "clock.arrow.circlepath",
                value: "\(orderViewModel.orderHistory.count)",
                label: LocalizationManager.shared.currentLanguage == .turkish ? "Siparişler" : "order_history".localized
            )
            
            StatCard(
                icon: "cart.fill",
                value: "\(orderViewModel.itemCount)",
                label: "cart_items".localized
            )
        }
        .padding(.horizontal, 20)
    }
}

struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    @State private var cardScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.brownMedium.opacity(0.2), AppTheme.brownDark.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.system(size: 26))
                    .foregroundColor(AppTheme.brownDark)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
            
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppTheme.brownMedium.opacity(0.3),
                            AppTheme.brownMedium.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .scaleEffect(cardScale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.95
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardScale = 1.0
                }
            }
        }
    }
}

struct ProfileMenuView: View {
    let user: User
    @ObservedObject var profileViewModel: UserProfileViewModel
    @ObservedObject var orderViewModel: OrderViewModel
    let onEditProfile: () -> Void
    let onShowFavorites: () -> Void
    let onShowOrderHistory: () -> Void
    let onShowLanguagePicker: () -> Void
    let onShowAbout: () -> Void
    let onShowAdminLogin: () -> Void
    let onLogout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            ProfileMenuRow(
                icon: "person.fill",
                title: "edit_profile".localized,
                color: AppTheme.brownDark
            ) {
                onEditProfile()
            }
            
            ProfileMenuRow(
                icon: "star.fill",
                title: "favorites".localized,
                subtitle: "\(orderViewModel.favoriteItems.count) \(LocalizationManager.shared.currentLanguage == .turkish ? "ürün" : "items")",
                color: AppTheme.brownMedium
            ) {
                onShowFavorites()
            }
            
            ProfileMenuRow(
                icon: "clock.arrow.circlepath",
                title: "order_history".localized,
                subtitle: "\(orderViewModel.orderHistory.count) \(LocalizationManager.shared.currentLanguage == .turkish ? "sipariş" : "orders")",
                color: AppTheme.brownMedium
            ) {
                onShowOrderHistory()
            }
            
            ProfileMenuRow(
                icon: "globe",
                title: "language".localized,
                subtitle: LocalizationManager.shared.currentLanguage.displayName,
                color: AppTheme.brownMedium
            ) {
                onShowLanguagePicker()
            }
            
            ProfileMenuRow(
                icon: "bell.fill",
                title: "notifications".localized,
                color: AppTheme.brownMedium,
                hasToggle: true,
                toggleValue: Binding(
                    get: { profileViewModel.currentUser?.preferences.notificationsEnabled ?? false },
                    set: { newValue in
                        var updatedPreferences = profileViewModel.currentUser?.preferences ?? UserPreferences()
                        updatedPreferences.notificationsEnabled = newValue
                        profileViewModel.updatePreferences(updatedPreferences)
                        
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }
                )
            )
            
            ProfileMenuRow(
                icon: "info.circle.fill",
                title: "about".localized,
                color: AppTheme.brownMedium
            ) {
                onShowAbout()
            }
            
            if !user.preferences.dietaryRestrictions.isEmpty {
                ProfileMenuRow(
                    icon: "exclamationmark.triangle.fill",
                    title: "dietary_restrictions".localized,
                    subtitle: user.preferences.dietaryRestrictions.joined(separator: ", "),
                    color: AppTheme.brownMedium
                ) {}
            }
            
            // Admin Login Button
            ProfileMenuRow(
                icon: "person.badge.key.fill",
                title: "Yönetici Girişi",
                color: AppTheme.brownDark
            ) {
                onShowAdminLogin()
            }
            
            // Logout Button
            Button(action: {
                onLogout()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 20))
                    Text("Çıkış Yap")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.red.opacity(0.3), lineWidth: 1.5)
                )
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 20)
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    let color: Color
    var hasToggle: Bool = false
    var toggleValue: Binding<Bool>? = nil
    var action: (() -> Void)? = nil
    @State private var rowScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            action?()
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, design: .rounded))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
                
                Spacer()
                
                if hasToggle, let toggleBinding = toggleValue {
                    Toggle("", isOn: toggleBinding)
                        .toggleStyle(SwitchToggleStyle(tint: AppTheme.brownDark))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(AppTheme.brownMedium)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.brownDark.opacity(0.1), radius: 12, x: 0, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .scaleEffect(rowScale)
        }
        .buttonStyle(.plain)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                rowScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    rowScale = 1.0
                }
            }
        }
    }
}

struct EmptyProfileView: View {
    let onCreateProfile: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 100))
                .foregroundColor(AppTheme.brownMedium.opacity(0.5))
            
            Text("create_profile".localized)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
            
            Text("create_profile_message".localized)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onCreateProfile) {
                HStack(spacing: 12) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 18))
                    Text("create_profile".localized)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [AppTheme.brownDark, AppTheme.brownMedium],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(20)
            }
            .padding(.horizontal, 40)
            .padding(.top, 20)
        }
        .padding(.vertical, 60)
    }
}

struct EditProfileView: View {
    @State private var user: User
    @ObservedObject var profileViewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isSaving = false
    
    init(user: User, profileViewModel: UserProfileViewModel) {
        _user = State(initialValue: user)
        self.profileViewModel = profileViewModel
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField(
                            "name".localized,
                            text: $user.name
                        )
                        .font(.system(size: 16, design: .rounded))
                        
                        TextField(
                            "email".localized,
                            text: $user.email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 16, design: .rounded))
                        
                        TextField(
                            "phone".localized,
                            text: $user.phoneNumber
                        )
                        .keyboardType(.phonePad)
                        .font(.system(size: 16, design: .rounded))
                    } header: {
                        Text("personal_information".localized)
                    }
                }
            }
            .navigationTitle("edit_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("cancel".localized)
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isSaving = true
                        profileViewModel.updateProfile(
                            name: user.name,
                            email: user.email,
                            phoneNumber: user.phoneNumber
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isSaving = false
                            dismiss()
                        }
                    }) {
                        if isSaving {
                            ProgressView()
                        } else {
                            Text("save".localized)
                                .foregroundColor(AppTheme.brownDark)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
    }
}

struct CreateProfileView: View {
    @ObservedObject var profileViewModel: UserProfileViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var isCreating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                Form {
                    Section {
                        TextField(
                            "name".localized,
                            text: $name
                        )
                        .font(.system(size: 16, design: .rounded))
                        
                        TextField(
                            "email".localized,
                            text: $email
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .font(.system(size: 16, design: .rounded))
                        
                        TextField(
                            "phone".localized,
                            text: $phoneNumber
                        )
                        .keyboardType(.phonePad)
                        .font(.system(size: 16, design: .rounded))
                    } header: {
                        Text("profile_information".localized)
                    } footer: {
                        Text("create_profile_message".localized)
                    }
                }
            }
            .navigationTitle("create_profile".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Text("cancel".localized)
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        guard !name.isEmpty else { return }
                        
                        isCreating = true
                        profileViewModel.createProfile(
                            name: name,
                            email: email,
                            phoneNumber: phoneNumber
                        )
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            isCreating = false
                            dismiss()
                        }
                    }) {
                        if isCreating {
                            ProgressView()
                        } else {
                            Text(LocalizationManager.shared.currentLanguage == .turkish ? "Oluştur" : "Create")
                                .foregroundColor(AppTheme.brownDark)
                                .fontWeight(.semibold)
                        }
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: (UIImage) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
                parent.selectedImage = image
                parent.onImageSelected(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var localizationManager = LocalizationManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        Image("logo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 120)
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Text("about_app".localized)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text("app_version".localized + " 1.0.0")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                        
                        VStack(alignment: .leading, spacing: 16) {
                            Text("app_description".localized)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                                .multilineTextAlignment(.leading)
                            
                            Divider()
                            
                            VStack(alignment: .leading, spacing: 12) {
                                Text("developer_info".localized)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                InfoRow(
                                    icon: "envelope.fill",
                                    title: "contact".localized,
                                    subtitle: "support@ustn.com"
                                )
                                
                                InfoRow(
                                    icon: "doc.text.fill",
                                    title: "privacy_policy".localized,
                                    subtitle: ""
                                )
                                
                                InfoRow(
                                    icon: "doc.fill",
                                    title: "terms_of_service".localized,
                                    subtitle: ""
                                )
                            }
                        }
                        .padding(20)
                        .background(AppTheme.cardBackground)
                        .cornerRadius(20)
                        .shadow(color: AppTheme.brownDark.opacity(0.08), radius: 10, x: 0, y: 4)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("about".localized)
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
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(AppTheme.brownMedium)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(AppTheme.brownMedium.opacity(0.5))
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProfileView(
        profileViewModel: UserProfileViewModel(),
        orderViewModel: OrderViewModel()
    )
}

