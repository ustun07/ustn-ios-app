import SwiftUI

struct ProductDetailView: View {
    let item: MenuItem
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var quantity: Int = 1
    @State private var scrollOffset: CGFloat = 0
    @State private var imageRotation: Double = 0
    @State private var imageScale: CGFloat = 1.0
    @State private var contentOpacity: Double = 0
    @State private var showAddedAnimation = false
    @State private var addButtonPulse: CGFloat = 1.0
    @State private var shimmerOffset: CGFloat = -200
    
    private var itemQuantity: Int {
        viewModel.orderItems.first(where: { $0.menuItem.id == item.id })?.quantity ?? 0
    }
    
    private var totalPrice: Double {
        item.price * Double(quantity)
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            // Floating orbs
            FloatingOrbsView()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Parallax hero section
                        ParallaxHeroImageView(
                            item: item,
                            scrollOffset: scrollOffset,
                            imageScale: $imageScale,
                            imageRotation: $imageRotation
                        )
                        .frame(height: 400)
                        .background(
                            GeometryReader { geo in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geo.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                        
                        // Floating content card
                        FloatingProductCard(
                            item: item,
                            viewModel: viewModel,
                            quantity: $quantity,
                            totalPrice: totalPrice,
                            itemQuantity: itemQuantity,
                            showAddedAnimation: $showAddedAnimation,
                            addButtonPulse: $addButtonPulse,
                            shimmerOffset: $shimmerOffset,
                            onAddToCart: {
                                for _ in 0..<quantity {
                                    viewModel.addItem(item)
                                }
                                withAnimation {
                                    showAddedAnimation = true
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    dismiss()
                                }
                            }
                        )
                        .opacity(contentOpacity)
                        .padding(.top, -60)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    viewModel.toggleFavorite(item)
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: viewModel.isFavorite(item) ? "heart.fill" : "heart")
                            .font(.system(size: 18))
                            .foregroundColor(viewModel.isFavorite(item) ? .red : AppTheme.brownMedium)
                    }
                }
            }
        }
        .contextMenu {
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                viewModel.toggleFavorite(item)
            }) {
                Label(
                    viewModel.isFavorite(item) ? "remove_from_favorites".localized : "add_to_favorites".localized,
                    systemImage: viewModel.isFavorite(item) ? "heart.slash.fill" : "heart.fill"
                )
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                imageScale = 1.1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.easeIn(duration: 0.5)) {
                    contentOpacity = 1.0
                }
            }
            
            // Continuous rotation animation
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                imageRotation = 360
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                addButtonPulse = 1.05
            }
            
            if itemQuantity > 0 {
                quantity = itemQuantity
            }
        }
    }
}

// MARK: - Parallax Hero Image View
struct ParallaxHeroImageView: View {
    let item: MenuItem
    let scrollOffset: CGFloat
    @Binding var imageScale: CGFloat
    @Binding var imageRotation: Double
    
    var parallaxOffset: CGFloat {
        scrollOffset * 0.5
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    AppTheme.brownDark.opacity(0.4),
                    AppTheme.brownMedium.opacity(0.3),
                    AppTheme.beigeMedium.opacity(0.2),
                    AppTheme.beigeLight.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Radial glow effect
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.brownMedium.opacity(0.3),
                            AppTheme.brownMedium.opacity(0.1),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 50,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: parallaxOffset * 0.3)
                .blur(radius: 40)
            
            // Product image with 3D effects (custom asset)
            VStack(spacing: 20) {
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .scaleEffect(imageScale + parallaxOffset / 1000)
                    .offset(y: parallaxOffset)
                    .rotation3DEffect(
                        .degrees(imageRotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.3
                    )
                    .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 30, x: 0, y: 15)
                
                // Category badge
                HStack(spacing: 8) {
                    Text(item.category.icon)
                        .font(.system(size: 18))
                    
                    Text(item.category.localizedName)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .shadow(color: Color.black.opacity(0.2), radius: 15, x: 0, y: 8)
                )
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                )
                .offset(y: parallaxOffset * 0.2)
            }
        }
    }
}

// MARK: - Floating Product Card
struct FloatingProductCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: OrderViewModel
    @Binding var quantity: Int
    let totalPrice: Double
    let itemQuantity: Int
    @Binding var showAddedAnimation: Bool
    @Binding var addButtonPulse: CGFloat
    @Binding var shimmerOffset: CGFloat
    let onAddToCart: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content card
            VStack(alignment: .leading, spacing: 24) {
                // Header section
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(item.name)
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                                .lineLimit(2)
                            
                            Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", item.price))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            viewModel.toggleFavorite(item)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 50, height: 50)
                                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: viewModel.isFavorite(item) ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(viewModel.isFavorite(item) ? .red : AppTheme.brownMedium)
                            }
                        }
                    }
                    
                    if itemQuantity > 0 {
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(AppTheme.brownMedium)
                            
                            Text(String(format: "already_in_cart".localized, itemQuantity))
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(AppTheme.beigeMedium.opacity(0.3))
                        )
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
                
                // Description section
                VStack(alignment: .leading, spacing: 12) {
                    Text("description".localized)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text(item.description)
                        .font(.system(size: 17, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                        .lineSpacing(8)
                        .fixedSize(horizontal: false, vertical: true)
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
                
                // Quantity selector
                ModernQuantitySelector(
                    quantity: $quantity,
                    totalPrice: totalPrice
                )
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 32)
                    .fill(.ultraThinMaterial)
                    .shadow(color: AppTheme.brownDark.opacity(0.2), radius: 30, x: 0, y: 15)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 32)
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
            
            // Add to cart button
            ModernAddToCartButton(
                quantity: quantity,
                totalPrice: totalPrice,
                showAddedAnimation: $showAddedAnimation,
                pulseScale: addButtonPulse,
                shimmerOffset: shimmerOffset,
                onTap: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    onAddToCart()
                }
            )
            .padding(.top, 24)
        }
    }
}

// MARK: - Modern Quantity Selector
struct ModernQuantitySelector: View {
    @Binding var quantity: Int
    let totalPrice: Double
    @State private var minusScale: CGFloat = 1.0
    @State private var plusScale: CGFloat = 1.0
    @State private var numberScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 16) {
            Text("quantity".localized)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 30) {
                // Minus button
                Button(action: {
                    if quantity > 1 {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            minusScale = 0.9
                            numberScale = 0.95
                        }
                        
                        quantity -= 1
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                minusScale = 1.0
                                numberScale = 1.0
                            }
                        }
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                quantity > 1 ?
                                LinearGradient(
                                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [AppTheme.beigeMedium.opacity(0.3), AppTheme.beigeLight.opacity(0.5)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)
                            .shadow(
                                color: quantity > 1 ? AppTheme.brownDark.opacity(0.3) : Color.clear,
                                radius: 12,
                                x: 0,
                                y: 6
                            )
                        
                        Image(systemName: "minus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(quantity > 1 ? .white : AppTheme.brownMedium.opacity(0.5))
                    }
                    .scaleEffect(minusScale)
                }
                .disabled(quantity <= 1)
                
                // Quantity display
                VStack(spacing: 8) {
                    Text("\(quantity)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                        .scaleEffect(numberScale)
                    
                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", totalPrice))
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                .frame(minWidth: 120)
                
                // Plus button
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        plusScale = 0.9
                        numberScale = 1.05
                    }
                    
                    quantity += 1
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            plusScale = 1.0
                            numberScale = 1.0
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
                            .frame(width: 56, height: 56)
                            .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 15, x: 0, y: 8)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(plusScale)
                }
            }
        }
    }
}

// MARK: - Modern Add to Cart Button
struct ModernAddToCartButton: View {
    let quantity: Int
    let totalPrice: Double
    @Binding var showAddedAnimation: Bool
    let pulseScale: CGFloat
    let shimmerOffset: CGFloat
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Base gradient
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: showAddedAnimation ?
                            [Color.green, Color.green.opacity(0.8)] :
                            [AppTheme.brownDark, AppTheme.brownMedium],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 64)
                    .shadow(
                        color: showAddedAnimation ?
                        Color.green.opacity(0.5) :
                        AppTheme.brownDark.opacity(0.5),
                        radius: 25,
                        x: 0,
                        y: 12
                    )
                
                // Shimmer effect
                if !showAddedAnimation {
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
                }
                
                // Content
                HStack(spacing: 16) {
                    if showAddedAnimation {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 26))
                            .transition(.scale.combined(with: .opacity))
                    } else {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 26))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(showAddedAnimation ? "added".localized : "add_to_cart".localized)
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                        
                        if !showAddedAnimation {
                            Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", totalPrice))
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .opacity(0.9)
                        }
                    }
                    
                    Spacer()
                    
                    if !showAddedAnimation {
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
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationView {
        ProductDetailView(
            item: MenuItem.sampleMenu.first!,
            viewModel: OrderViewModel()
        )
    }
}
