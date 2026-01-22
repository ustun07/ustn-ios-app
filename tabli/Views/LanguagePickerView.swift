import SwiftUI

struct LanguagePickerView: View {
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage: AppLanguage
    
    init() {
        _selectedLanguage = State(initialValue: LocalizationManager.shared.currentLanguage)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {

                        VStack(spacing: 16) {
                            Image(systemName: "globe")
                                .font(.system(size: 50))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text(localizationManager.currentLanguage == .turkish ? "Dil Seçin" : "Select Language")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text(localizationManager.currentLanguage == .turkish ? 
                                 "Uygulamanın görüntüleneceği dili seçin" :
                                 "Choose the language for the app")
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        .padding(.top, 30)
                        .padding(.bottom, 20)
                        

                        VStack(spacing: 16) {
                            ForEach(AppLanguage.allCases) { language in
                                LanguageOptionCard(
                                    language: language,
                                    isSelected: selectedLanguage == language
                                ) {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    selectedLanguage = language
                                    localizationManager.setLanguage(language)
                                    

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        dismiss()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
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
        }
    }
}

struct LanguageOptionCard: View {
    let language: AppLanguage
    let isSelected: Bool
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.97
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            HStack(spacing: 20) {

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
                        .frame(width: 60, height: 60)
                        .shadow(
                            color: isSelected ?
                            AppTheme.brownDark.opacity(0.3) :
                            AppTheme.brownMedium.opacity(0.1),
                            radius: isSelected ? 8 : 4,
                            x: 0,
                            y: isSelected ? 4 : 2
                        )
                    
                    Text(language == .turkish ? "🇹🇷" : "🇬🇧")
                        .font(.system(size: 32))
                }
                

                VStack(alignment: .leading, spacing: 6) {
                    Text(language.displayName)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? AppTheme.brownDark : AppTheme.brownDark)
                    
                    Text(language.nativeName)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(isSelected ? AppTheme.brownMedium : AppTheme.brownMedium)
                }
                
                Spacer()
                

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppTheme.brownDark)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                isSelected ?
                AppTheme.beigeLight.opacity(0.6) :
                AppTheme.cardBackground
            )
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        isSelected ?
                        AppTheme.brownMedium.opacity(0.4) :
                        AppTheme.brownMedium.opacity(0.15),
                        lineWidth: isSelected ? 2 : 1.5
                    )
            )
            .shadow(
                color: isSelected ?
                AppTheme.brownDark.opacity(0.15) :
                AppTheme.brownDark.opacity(0.05),
                radius: isSelected ? 10 : 5,
                x: 0,
                y: isSelected ? 5 : 2
            )
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LanguagePickerView()
}
