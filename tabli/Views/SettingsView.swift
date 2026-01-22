import SwiftUI

struct SettingsView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @ObservedObject var themeManager = ThemeManager.shared
    @ObservedObject var notificationService = NotificationService.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: AppLanguage
    @State private var notificationsEnabled: Bool = false
    
    init() {
        _selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        // MARK: - Theme Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Text(localizationManager.currentLanguage == .turkish ? "Tema" : "Theme")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            HStack(spacing: 12) {
                                ForEach(ThemeManager.Theme.allCases, id: \.rawValue) { theme in
                                    ThemeOptionButton(
                                        theme: theme,
                                        isSelected: themeManager.currentTheme == theme
                                    ) {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            themeManager.currentTheme = theme
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.brownDark.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // MARK: - Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Text(localizationManager.currentLanguage == .turkish ? "Bildirimler" : "Notifications")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Spacer()
                                
                                Toggle("", isOn: $notificationsEnabled)
                                    .labelsHidden()
                                    .tint(AppTheme.brownDark)
                                    .onChange(of: notificationsEnabled) { _, newValue in
                                        if newValue {
                                            notificationService.requestPermission { granted in
                                                notificationsEnabled = granted
                                            }
                                        }
                                    }
                            }
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            
                            if notificationsEnabled {
                                VStack(alignment: .leading, spacing: 8) {
                                    NotificationInfoRow(
                                        icon: "bag.fill",
                                        text: localizationManager.currentLanguage == .turkish ? 
                                            "Sipariş hazır bildirimleri" : "Order ready notifications"
                                    )
                                    NotificationInfoRow(
                                        icon: "tag.fill",
                                        text: localizationManager.currentLanguage == .turkish ? 
                                            "Kampanya bildirimleri" : "Promotion notifications"
                                    )
                                }
                                .padding(.horizontal, 24)
                                .padding(.bottom, 20)
                            }
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(color: AppTheme.brownDark.opacity(0.08), radius: 12, x: 0, y: 4)
                        .padding(.horizontal, 20)

                        // MARK: - Language Section
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "globe")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Text(LocalizationManager.shared.currentLanguage == .turkish ? "Dil" : "Language")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            
                            VStack(spacing: 12) {
                                ForEach(AppLanguage.allCases) { language in
                                    LanguageOptionRow(
                                        language: language,
                                        isSelected: selectedLanguage == language
                                    ) {
                                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                        impactFeedback.impactOccurred()
                                        
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            selectedLanguage = language
                                            localizationManager.setLanguage(language)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                        .background(AppTheme.cardBackground)
                        .cornerRadius(24)
                        .shadow(
                            color: AppTheme.brownDark.opacity(0.08),
                            radius: 12,
                            x: 0,
                            y: 4
                        )
                        .padding(.horizontal, 20)
                    }
                }
            }
            .navigationTitle("Settings")
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
            .onAppear {
                notificationService.checkPermissionStatus { status in
                    notificationsEnabled = status == .authorized
                }
            }
        }
    }
}

// MARK: - Theme Option Button

struct ThemeOptionButton: View {
    let theme: ThemeManager.Theme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? 
                              LinearGradient(colors: [AppTheme.brownDark, AppTheme.brownMedium], startPoint: .topLeading, endPoint: .bottomTrailing) :
                              LinearGradient(colors: [AppTheme.beigeLight, AppTheme.beigeMedium.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? .white : AppTheme.brownMedium)
                }
                
                Text(theme.rawValue)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? AppTheme.brownDark : AppTheme.brownMedium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? AppTheme.beigeLight.opacity(0.5) : Color.clear)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? AppTheme.brownMedium.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notification Info Row

struct NotificationInfoRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(AppTheme.brownMedium)
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundColor(.green.opacity(0.7))
        }
    }
}

struct LanguageOptionRow: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.98
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            HStack(spacing: 16) {

                ZStack {
                    Circle()
                        .fill(
                            isSelected ?
                            LinearGradient(
                                colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) :
                            LinearGradient(
                                colors: [AppTheme.beigeLight, AppTheme.beigeMedium.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Text(language == .turkish ? "🇹🇷" : "🇬🇧")
                        .font(.system(size: 24))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(isSelected ? AppTheme.brownDark : AppTheme.brownDark)
                    
                    Text(language.nativeName)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(isSelected ? AppTheme.brownMedium : AppTheme.brownMedium)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(AppTheme.brownDark)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(18)
            .background(
                isSelected ?
                AppTheme.beigeLight.opacity(0.5) :
                Color.clear
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                        AppTheme.brownMedium.opacity(0.3) :
                        AppTheme.brownMedium.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
}
