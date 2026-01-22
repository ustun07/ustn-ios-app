import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: OrderViewModel
    @ObservedObject var localizationManager = LocalizationManager.shared
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var isAnimating = false
    @State private var showTableSelection = false
    @State private var selectedTable: Table?
    @State private var showMenu = false
    @State private var showOrderStatus = false
    @State private var showLanguagePicker = false
    @State private var showFavorites = false
    @State private var showOrderHistory = false
    @State private var showQRScanner = false
    @State private var showProfile = false
    @State private var showAuthMenu = false
    @State private var logoScale: CGFloat = 1.0
    @State private var logoOffset: CGFloat = 0
    @State private var steamOpacity: Double = 0
    @State private var steamOffset: CGFloat = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var showNotificationBanner = false
    @State private var notificationTitle = ""
    @State private var notificationMessage = ""
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            // Floating orbs
            FloatingOrbsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // In-app notification banner
                if showNotificationBanner {
                    NotificationBannerView(
                        title: notificationTitle,
                        message: notificationMessage,
                        onDismiss: {
                            withAnimation(.spring()) {
                                showNotificationBanner = false
                            }
                        }
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .zIndex(100)
                }
                
                ScrollView {
                VStack(spacing: 0) {
                    // Top bar with profile and language
                    HStack {
                        Spacer()
                        HStack(spacing: 12) {
                            Button(action: {
                                // Giriş yapılmışsa profil, yapılmamışsa giriş menüsü göster
                                if profileViewModel.currentUser != nil {
                                    showProfile = true
                                } else {
                                    showAuthMenu = true
                                }
                            }) {
                                if let user = profileViewModel.currentUser,
                                   let imageData = user.profileImageData,
                                   let uiImage = UIImage(data: imageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 40, height: 40)
                                        .clipShape(Circle())
                                        .overlay(
                                            Circle()
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [AppTheme.brownMedium, AppTheme.brownDark],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 2.5
                                                )
                                        )
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
                                            .frame(width: 40, height: 40)
                                        
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.white)
                                    }
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.brownMedium, lineWidth: 2.5)
                                    )
                                }
                            }
                            
                            // Theme toggle button
                            Button(action: {
                                let themeManager = ThemeManager.shared
                                if themeManager.currentTheme == .dark {
                                    themeManager.currentTheme = .light
                                } else {
                                    themeManager.currentTheme = .dark
                                }
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                            }) {
                                Image(systemName: ThemeManager.shared.currentTheme == .dark ? "moon.fill" : "sun.max.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(AppTheme.brownDark)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(.ultraThinMaterial)
                                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                                    )
                            }
                            
                            Button(action: {
                                showLanguagePicker = true
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: "globe")
                                        .font(.system(size: 16))
                                    Text(localizationManager.currentLanguage == .turkish ? "TR" : "EN")
                                        .font(.system(size: 15, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(AppTheme.brownDark)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                    }
                    
                    // Logo section with coffee steam animation
                    VStack(spacing: 20) {
                        ZStack {
                            // Coffee steam particles
                            ForEach(0..<5) { index in
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                AppTheme.brownMedium.opacity(0.3),
                                                AppTheme.brownMedium.opacity(0.1),
                                                Color.clear
                                            ],
                                            center: .center,
                                            startRadius: 2,
                                            endRadius: 15
                                        )
                                    )
                                    .frame(width: 20 + CGFloat(index * 3), height: 20 + CGFloat(index * 3))
                                    .offset(
                                        x: CGFloat(index - 2) * 15,
                                        y: steamOffset - CGFloat(index * 8) - 80
                                    )
                                    .opacity(steamOpacity * (1.0 - Double(index) * 0.15))
                                    .blur(radius: 5)
                            }
                            
                            // Glow circle (coffee cup glow)
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            AppTheme.brownMedium.opacity(0.3),
                                            AppTheme.brownMedium.opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 180, height: 180)
                                .scaleEffect(logoScale)
                                .blur(radius: 20)
                            
                            // Logo with breathing effect
                            Image("logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 320, height: 320)
                                .scaleEffect(logoScale)
                                .offset(y: logoOffset)
                                .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 15, x: 0, y: 8)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                    }
                    
                    // Table selection card
                    VStack(spacing: 20) {
                        if let table = viewModel.currentTable {
                            // Selected table card
                            ModernTableCard(
                                table: table,
                                onChange: {
                                    showTableSelection = true
                                }
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        } else {
                            // Select table button
                            Button(action: {
                                showTableSelection = true
                            }) {
                                HStack(spacing: 16) {
                                    ZStack {
                                        Circle()
                                            .fill(
                                                LinearGradient(
                                                    colors: [AppTheme.brownDark.opacity(0.2), AppTheme.brownMedium.opacity(0.1)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .frame(width: 56, height: 56)
                                        
                                        Image(systemName: "number")
                                            .font(.system(size: 24))
                                            .foregroundColor(AppTheme.brownDark)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("select_table".localized)
                                            .font(.system(size: 20, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.brownDark)
                                        
                                        Text("tap_to_select".localized)
                                            .font(.system(size: 14, design: .rounded))
                                            .foregroundColor(AppTheme.brownMedium)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(AppTheme.brownMedium)
                                }
                                .padding(20)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                        .shadow(color: AppTheme.brownDark.opacity(0.15), radius: 20, x: 0, y: 10)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 24)
                                        .stroke(
                                            LinearGradient(
                                                colors: [
                                                    AppTheme.brownMedium.opacity(0.4),
                                                    AppTheme.brownMedium.opacity(0.2)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        }
                    }
                    
                    // Main action buttons
                    VStack(spacing: 16) {
                        // Start Order button
                        Button(action: {
                            if viewModel.currentTable == nil {
                                showTableSelection = true
                            } else {
                                showMenu = true
                            }
                        }) {
                            ZStack {
                                // Base gradient
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 70)
                                    .shadow(color: AppTheme.brownDark.opacity(0.5), radius: 25, x: 0, y: 12)
                                
                                // Shimmer effect
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.clear,
                                                Color.white.opacity(0.3),
                                                Color.clear
                                            ],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(height: 70)
                                    .offset(x: shimmerOffset)
                                    .mask(RoundedRectangle(cornerRadius: 28))
                                
                                HStack(spacing: 16) {
                                    Image(systemName: "cart.fill")
                                        .font(.system(size: 26))
                                    
                                    Text("start_order".localized)
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 28)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                            )
                            .scaleEffect(isAnimating ? 1.02 : 1.0)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Quick actions grid
                        VStack(spacing: 12) {
                            // QR Scanner button
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                showQRScanner = true
                            }) {
                                ModernQuickActionButton(
                                    icon: "qrcode.viewfinder",
                                    title: "scan_qr_code".localized,
                                    color: AppTheme.brownMedium
                                )
                            }
                            
                            // Favorites and Order History
                            HStack(spacing: 12) {
                                Button(action: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    showFavorites = true
                                }) {
                                    ModernQuickActionButton(
                                        icon: "star.fill",
                                        title: "favorites".localized,
                                        color: AppTheme.brownMedium,
                                        isCompact: true
                                    )
                                }
                                
                                Button(action: {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    showOrderHistory = true
                                }) {
                                    ModernQuickActionButton(
                                        icon: "clock.arrow.circlepath",
                                        title: "order_history".localized,
                                        color: AppTheme.brownMedium,
                                        isCompact: true
                                    )
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Order Status button (if active)
                        if viewModel.orderStatus != .none {
                            Button(action: {
                                showOrderStatus = true
                            }) {
                                ModernQuickActionButton(
                                    icon: "clock.fill",
                                    title: "order_status".localized,
                                    color: AppTheme.brownDark,
                                    isCompact: false
                                )
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 8)
                        }
                    }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            isAnimating = true
            
            // Breathing/pulse animation (like coffee steam rising)
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                logoScale = 1.08
            }
            
            // Gentle floating animation (like coffee cup on table)
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                logoOffset = -8
            }
            
            // Coffee steam animation
            withAnimation(.easeOut(duration: 2.0).repeatForever(autoreverses: false)) {
                steamOffset = -120
                steamOpacity = 0.8
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .inAppNotification)) { notification in
            if let userInfo = notification.userInfo,
               let title = userInfo["title"] as? String,
               let message = userInfo["message"] as? String {
                
                withAnimation(.spring()) {
                    self.notificationTitle = title
                    self.notificationMessage = message
                    self.showNotificationBanner = true
                }
                
                // 5 saniye sonra otomatik kapat
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    withAnimation(.spring()) {
                        self.showNotificationBanner = false
                    }
                }
            }
        }
        .sheet(isPresented: $showTableSelection) {
            TableSelectionView(
                selectedTable: $selectedTable,
                onSelect: { table in
                    viewModel.currentTable = table
                    showTableSelection = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $showMenu) {
            MenuView(viewModel: viewModel) {
                showMenu = false
            }
            .environmentObject(profileViewModel)
        }
        .sheet(isPresented: $showOrderStatus) {
            OrderStatusView(viewModel: viewModel)
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguagePickerView()
        }
        .sheet(isPresented: $showFavorites) {
            FavoritesView(viewModel: viewModel)
        }
        .sheet(isPresented: $showOrderHistory) {
            OrderHistoryView(viewModel: viewModel)
        }
        .sheet(isPresented: $showQRScanner) {
            QRCodeScannerView(viewModel: viewModel)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView(
                profileViewModel: profileViewModel,
                orderViewModel: viewModel
            )
        }
        .sheet(isPresented: $showAuthMenu) {
            AuthMenuView()
                .environmentObject(profileViewModel)
                .environmentObject(viewModel)
        }
    }
}

// MARK: - Notification Banner View
struct NotificationBannerView: View {
    let title: String
    let message: String
    let onDismiss: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 44, height: 44)
                
                Image(systemName: "bell.fill")
                    .font(.system(size: 20))
                    .foregroundColor(AppTheme.brownDark)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(2)
            }
            
            Spacer()
            
            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(8)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.brownDark, AppTheme.brownMedium],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Modern Table Card
struct ModernTableCard: View {
    let table: Table
    let onChange: () -> Void
    @State private var cardScale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            onChange()
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                        .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 15, x: 0, y: 8)
                    
                    DiningTableIcon(size: 36, color: .white)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("table".localized)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                    
                    Text("\(table.number)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.system(size: 18))
                        .foregroundColor(AppTheme.brownMedium)
                    
                    Text("change".localized)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.brownDark.opacity(0.2), radius: 25, x: 0, y: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.brownMedium.opacity(0.4),
                                AppTheme.brownMedium.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(cardScale)
        }
        .buttonStyle(.plain)
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.97
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardScale = 1.0
                }
            }
        }
    }
}

// MARK: - Modern Quick Action Button
struct ModernQuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    var isCompact: Bool = false
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: isCompact ? 44 : 50, height: isCompact ? 44 : 50)
                
                Image(systemName: icon)
                    .font(.system(size: isCompact ? 18 : 20))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.system(size: isCompact ? 16 : 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(isCompact ? 16 : 20)
        .background(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.1), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: isCompact ? 20 : 24)
                .stroke(
                    LinearGradient(
                        colors: [
                            color.opacity(0.4),
                            color.opacity(0.2)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    lineWidth: 1.5
                )
        )
    }
}

struct TableSelectionView: View {
    @Binding var selectedTable: Table?
    let onSelect: (Table) -> Void
    @Environment(\.dismiss) var dismiss
    @State private var animateIn = false
    @Namespace private var tableNamespace
    
    private var gridColumns: [GridItem] {
        let itemSize: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 120 : 90
        let spacing: CGFloat = 20
        let padding: CGFloat = 40
        let availableWidth = UIScreen.main.bounds.width - padding * 2
        let columnsCount = Int((availableWidth + spacing) / (itemSize + spacing))
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(3, columnsCount))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            Text("🪑")
                                .font(.system(size: 60))
                                .scaleEffect(animateIn ? 1.0 : 0.8)
                                .opacity(animateIn ? 1.0 : 0)
                            
                            Text("select_your_table".localized)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text("choose_table_message".localized)
                                .font(.system(size: 16, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        LazyVGrid(columns: gridColumns, spacing: 20) {
                            ForEach(Table.availableTables) { table in
                                ModernTableSelectionCard(
                                    table: table,
                                    isSelected: selectedTable?.id == table.id,
                                    namespace: tableNamespace
                                ) {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                    impactFeedback.impactOccurred()
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        selectedTable = table
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        onSelect(table)
                                        dismiss()
                                    }
                                }
                                .opacity(animateIn ? 1.0 : 0)
                                .offset(y: animateIn ? 0 : 20)
                                .animation(
                                    .spring(response: 0.4, dampingFraction: 0.7)
                                    .delay(Double(table.id) * 0.03),
                                    value: animateIn
                                )
                            }
                        }
                        .padding(.horizontal, 30)
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
            .onAppear {
                withAnimation {
                    animateIn = true
                }
            }
        }
    }
}

struct ModernTableSelectionCard: View {
    let table: Table
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                scale = 1.15
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    scale = 1.0
                }
            }
            
            action()
        }) {
            VStack(spacing: 12) {
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
                        .frame(width: 70, height: 70)
                        .shadow(
                            color: isSelected ?
                            AppTheme.brownDark.opacity(0.4) :
                            AppTheme.brownMedium.opacity(0.2),
                            radius: isSelected ? 12 : 6,
                            x: 0,
                            y: isSelected ? 6 : 3
                        )
                    
                    DiningTableIcon(size: 30, color: isSelected ? .white : AppTheme.brownDark)
                }
                
                Text("\(table.number)")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppTheme.brownDark)
                
                Text("table".localized)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? .white.opacity(0.9) : AppTheme.brownMedium)
            }
            .frame(width: 90, height: 130)
            .padding(.vertical, 16)
            .padding(.horizontal, 10)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .matchedGeometryEffect(id: "selectedTable", in: namespace)
                    } else {
                        RoundedRectangle(cornerRadius: 28)
                            .fill(.ultraThinMaterial)
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        isSelected ?
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) :
                        LinearGradient(
                            colors: [
                                AppTheme.brownMedium.opacity(0.3),
                                AppTheme.brownMedium.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isSelected ? 2.5 : 1.5
                    )
            )
            .scaleEffect(scale)
            .shadow(
                color: isSelected ?
                AppTheme.brownDark.opacity(0.5) :
                AppTheme.brownDark.opacity(0.1),
                radius: isSelected ? 15 : 8,
                x: 0,
                y: isSelected ? 8 : 4
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(viewModel: OrderViewModel())
}
