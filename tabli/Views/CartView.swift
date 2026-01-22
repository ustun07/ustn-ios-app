import SwiftUI

struct CartView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    var onOrderComplete: (() -> Void)?
    @State private var showOrderConfirmation = false
    @State private var isPlacingOrder = false
    @State private var showProfile = false
    @State private var scrollOffset: CGFloat = 0
    @State private var animateIn = false
    @Namespace private var itemNamespace
    
    init(viewModel: OrderViewModel, onOrderComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onOrderComplete = onOrderComplete
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                // Floating orbs
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                if viewModel.orderItems.isEmpty {
                    EmptyCartView()
                } else {
                    VStack(spacing: 0) {
                        GeometryReader { geometry in
                            ScrollView {
                                VStack(spacing: 0) {
                                    // Hero header with parallax
                                    CartHeroHeader(
                                        itemCount: viewModel.itemCount,
                                        scrollOffset: scrollOffset
                                    )
                                    .frame(height: 180)
                                    .background(
                                        GeometryReader { geo in
                                            Color.clear.preference(
                                                key: ScrollOffsetPreferenceKey.self,
                                                value: geo.frame(in: .named("scroll")).minY
                                            )
                                        }
                                    )
                                    
                                    // Floating items cards
                                    LazyVStack(spacing: 16) {
                                        ForEach(Array(viewModel.orderItems.enumerated()), id: \.element.id) { index, orderItem in
                                            ModernCartItemCard(
                                                orderItem: orderItem,
                                                viewModel: viewModel,
                                                namespace: itemNamespace
                                            )
                                            .opacity(animateIn ? 1 : 0)
                                            .offset(y: animateIn ? 0 : 30)
                                            .animation(
                                                .spring(response: 0.6, dampingFraction: 0.75)
                                                .delay(Double(index) * 0.08),
                                                value: animateIn
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.top, -40)
                                    .padding(.bottom, 20)
                                }
                            }
                            .coordinateSpace(name: "scroll")
                            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                                scrollOffset = value
                            }
                        }
                        
                        // Floating summary card
                        ModernCartSummaryCard(
                            viewModel: viewModel,
                            isPlacingOrder: $isPlacingOrder,
                            onPlaceOrder: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                impactFeedback.impactOccurred()
                                
                                isPlacingOrder = true
                                viewModel.placeOrder()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    showOrderConfirmation = true
                                    isPlacingOrder = false
                                }
                            }
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color.clear,
                                    AppTheme.beigeLight.opacity(0.8),
                                    AppTheme.beigeLight.opacity(0.9)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    }
                }
            }
            .navigationTitle("your_order".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button(action: {
                            showProfile = true
                        }) {
                            if let user = profileViewModel.currentUser,
                               let imageData = user.profileImageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 32, height: 32)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(AppTheme.brownMedium, lineWidth: 1.5))
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
                                        .frame(width: 32, height: 32)
                                    
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                }
                                .overlay(Circle().stroke(AppTheme.brownMedium, lineWidth: 1.5))
                            }
                        }
                        
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                    }
                }
            }
            .fullScreenCover(isPresented: $showOrderConfirmation) {
                OrderConfirmationView(viewModel: viewModel) {
                    onOrderComplete?()
                    dismiss()
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(
                    profileViewModel: profileViewModel,
                    orderViewModel: viewModel
                )
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateIn = true
                }
            }
        }
    }
}

// MARK: - Cart Hero Header
struct CartHeroHeader: View {
    let itemCount: Int
    let scrollOffset: CGFloat
    
    var parallaxOffset: CGFloat {
        scrollOffset * 0.3
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.brownDark.opacity(0.3),
                    AppTheme.brownMedium.opacity(0.2),
                    AppTheme.beigeMedium.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            VStack(spacing: 12) {
                Text("🍽️")
                    .font(.system(size: 80))
                    .offset(y: parallaxOffset)
                    .scaleEffect(1 + parallaxOffset / 1000)
                
                VStack(spacing: 6) {
                    Text("\(itemCount) \(itemCount == 1 ? "item".localized : "items".localized)")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("your_order".localized)
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                .offset(y: parallaxOffset * 0.2)
            }
        }
    }
}

// MARK: - Modern Cart Item Card
struct ModernCartItemCard: View {
    let orderItem: OrderItem
    @ObservedObject var viewModel: OrderViewModel
    let namespace: Namespace.ID
    @State private var cardScale: CGFloat = 1.0
    @State private var imageRotation: Double = 0
    @State private var minusScale: CGFloat = 1.0
    @State private var plusScale: CGFloat = 1.0
    
    var body: some View {
        HStack(spacing: 16) {
            // Image with 3D effect
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.beigeLight,
                                AppTheme.beigeMedium.opacity(0.7),
                                AppTheme.brownMedium.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: AppTheme.brownDark.opacity(0.25), radius: 15, x: 0, y: 8)
                
                Image(orderItem.menuItem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .rotation3DEffect(
                        .degrees(imageRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.2
                    )
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.brownMedium.opacity(0.4),
                                AppTheme.brownMedium.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(orderItem.menuItem.name)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .lineLimit(1)
                
                // Porsiyon seçeneği (sadece yiyecekler için)
                if orderItem.menuItem.category.hasPortionOption {
                    PortionSelectorView(orderItem: orderItem, viewModel: viewModel)
                }
                
                Text("\(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", orderItem.menuItem.price)) \("each".localized)")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
                
                Text("\("total".localized): \(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", orderItem.totalPrice))")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
            }
            
            Spacer()
            
            // Quantity controls
            VStack(spacing: 14) {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        plusScale = 1.3
                        cardScale = 1.05
                        imageRotation = 15
                    }
                    
                    viewModel.addItem(orderItem.menuItem)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            plusScale = 1.0
                            cardScale = 1.0
                            imageRotation = 0
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(plusScale)
                }
                
                // Quantity display
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(width: 50, height: 36)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Text("\(orderItem.quantity)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                }
                .overlay(
                    Capsule()
                        .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                )
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        minusScale = 1.3
                        cardScale = 0.95
                        imageRotation = -15
                    }
                    
                    viewModel.removeItem(orderItem)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            minusScale = 1.0
                            cardScale = 1.0
                            imageRotation = 0
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownMedium.opacity(0.8), AppTheme.brownMedium],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 40, height: 40)
                            .shadow(color: AppTheme.brownMedium.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: "minus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(minusScale)
                }
            }
        }
        .padding(22)
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
                            AppTheme.brownMedium.opacity(0.2),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
        )
        .scaleEffect(cardScale)
    }
}

// MARK: - Modern Cart Summary Card
struct ModernCartSummaryCard: View {
    @ObservedObject var viewModel: OrderViewModel
    @Binding var isPlacingOrder: Bool
    let onPlaceOrder: () -> Void
    @State private var shimmerOffset: CGFloat = -200
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            // Summary info
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("subtotal".localized)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.brownMedium)
                        
                        Text("total".localized)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("\(viewModel.itemCount) \(viewModel.itemCount == 1 ? "item".localized : "items".localized)")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppTheme.brownMedium)
                        
                        Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", viewModel.totalPrice))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                    }
                }
                
                Divider()
                    .background(
                        LinearGradient(
                            colors: [
                                AppTheme.brownMedium.opacity(0.3),
                                AppTheme.brownMedium.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                // Special notes
                VStack(alignment: .leading, spacing: 12) {
                    Text("special_notes".localized)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    TextField(
                        "special_notes_placeholder".localized,
                        text: $viewModel.specialNotes,
                        axis: .vertical
                    )
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 1.5)
                    )
                    .lineLimit(3...6)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.brownDark.opacity(0.2), radius: 20, x: 0, y: 10)
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
            
            // Place order button
            Button(action: onPlaceOrder) {
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
                        .frame(height: 64)
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
                        .frame(height: 64)
                        .offset(x: shimmerOffset)
                        .mask(RoundedRectangle(cornerRadius: 28))
                    
                    // Content
                    HStack(spacing: 16) {
                        if isPlacingOrder {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.3)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 26))
                        }
                        
                        Text("place_order".localized)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        Spacer()
                        
                        if !isPlacingOrder {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                )
                .scaleEffect(pulseScale)
            }
            .disabled(isPlacingOrder)
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 30, x: 0, y: 15)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
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
        .onAppear {
            // Shimmer animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.03
            }
        }
    }
}

// MARK: - Empty Cart View
struct EmptyCartView: View {
    @State private var animateEmoji = false
    @State private var rotate: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                // Glow effect
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
                    .frame(width: 200, height: 200)
                    .scaleEffect(animateEmoji ? 1.2 : 1.0)
                    .opacity(animateEmoji ? 0.8 : 1.0)
                    .blur(radius: 20)
                
                Text("🛒")
                    .font(.system(size: 120))
                    .scaleEffect(animateEmoji ? 1.1 : 1.0)
                    .rotationEffect(.degrees(rotate))
            }
            
            VStack(spacing: 16) {
                Text("cart_empty".localized)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Text("add_items_message".localized)
                    .font(.system(size: 18, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(6)
            }
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                animateEmoji = true
            }
            
            withAnimation(
                .linear(duration: 10)
                .repeatForever(autoreverses: false)
            ) {
                rotate = 360
            }
        }
    }
}

#Preview {
    CartView(viewModel: OrderViewModel())
}
