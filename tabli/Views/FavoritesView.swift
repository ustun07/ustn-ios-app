import SwiftUI

struct FavoritesView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: MenuCategory?
    @State private var scrollOffset: CGFloat = 0
    @State private var animateIn = false
    
    var favoriteItemsByCategory: [MenuCategory: [MenuItem]] {
        Dictionary(grouping: viewModel.favoriteItems) { $0.category }
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
                
                if viewModel.favoriteItems.isEmpty {
                    EmptyFavoritesView()
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Hero section
                                FavoritesHeroSection(
                                    itemCount: viewModel.favoriteItems.count,
                                    scrollOffset: scrollOffset
                                )
                                .frame(height: 220)
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: ScrollOffsetPreferenceKey.self,
                                            value: geo.frame(in: .named("scroll")).minY
                                        )
                                    }
                                )
                                
                                // Items grid
                                LazyVStack(spacing: 20) {
                                    ForEach(MenuCategory.allCases) { category in
                                        if let items = favoriteItemsByCategory[category], !items.isEmpty {
                                            ModernFavoriteCategorySection(
                                                category: category,
                                                items: items,
                                                viewModel: viewModel,
                                                animateIn: animateIn
                                            )
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, -40)
                                .padding(.bottom, 100)
                            }
                        }
                        .coordinateSpace(name: "scroll")
                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                            scrollOffset = value
                        }
                    }
                }
            }
            .navigationTitle("favorites".localized)
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
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateIn = true
                }
            }
        }
    }
}

// MARK: - Favorites Hero Section
struct FavoritesHeroSection: View {
    let itemCount: Int
    let scrollOffset: CGFloat
    
    var parallaxOffset: CGFloat {
        scrollOffset * 0.4
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
            
            VStack(spacing: 16) {
                Text("⭐")
                    .font(.system(size: 80))
                    .offset(y: parallaxOffset)
                    .scaleEffect(1 + parallaxOffset / 1000)
                    .rotationEffect(.degrees(parallaxOffset * 0.1))
                
                VStack(spacing: 8) {
                    Text("\(itemCount) \(LocalizationManager.shared.currentLanguage == .turkish ? "favori ürün" : "favorite items")")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("favorites".localized)
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                .offset(y: parallaxOffset * 0.3)
            }
        }
    }
}

// MARK: - Modern Favorite Category Section
struct ModernFavoriteCategorySection: View {
    let category: MenuCategory
    let items: [MenuItem]
    @ObservedObject var viewModel: OrderViewModel
    let animateIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Category header
            HStack {
                HStack(spacing: 12) {
                    Text(category.icon)
                        .font(.system(size: 28))
                    
                    Text(category.localizedName)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                }
                
                Spacer()
                
                ZStack {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(height: 32)
                        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    
                    Text("\(items.count)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                        .padding(.horizontal, 16)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
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
                                AppTheme.brownMedium.opacity(0.4),
                                AppTheme.brownMedium.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            
            // Items grid
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    NavigationLink(destination: ProductDetailView(item: item, viewModel: viewModel)) {
                        ModernFavoriteCard(
                            item: item,
                            viewModel: viewModel
                        )
                    }
                    .buttonStyle(.plain)
                    .opacity(animateIn ? 1 : 0)
                    .offset(y: animateIn ? 0 : 30)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.75)
                        .delay(Double(index) * 0.06),
                        value: animateIn
                    )
                }
            }
        }
        .padding(.bottom, 20)
    }
}

// MARK: - Modern Favorite Card
struct ModernFavoriteCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: OrderViewModel
    @State private var cardScale: CGFloat = 1.0
    @State private var imageScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section
            ZStack {
                RoundedRectangle(cornerRadius: 24)
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
                    .frame(height: 160)
                
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .scaleEffect(imageScale)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0),
                        perspective: 0.2
                    )
                
                // Favorite button
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            viewModel.toggleFavorite(item)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(12)
                    }
                    Spacer()
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24
                )
            )
            
            // Content section
            VStack(alignment: .leading, spacing: 12) {
                Text(item.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .lineLimit(1)
                
                Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", item.price))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        cardScale = 0.95
                        imageScale = 1.3
                        rotation = 10
                    }
                    
                    viewModel.addItem(item)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            cardScale = 1.0
                            imageScale = 1.0
                            rotation = 0
                        }
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.badge.plus")
                            .font(.system(size: 16))
                        Text("add_to_cart".localized)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.2), radius: 20, x: 0, y: 10)
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
    }
}

// MARK: - Empty Favorites View
struct EmptyFavoritesView: View {
    @State private var animateEmoji = false
    @State private var rotate: Double = 0
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.brownMedium.opacity(0.3),
                                AppTheme.brownMedium.opacity(0.1),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 40,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)
                    .scaleEffect(animateEmoji ? 1.2 : 1.0)
                    .opacity(animateEmoji ? 0.8 : 1.0)
                    .blur(radius: 30)
                
                Text("⭐")
                    .font(.system(size: 100))
                    .scaleEffect(animateEmoji ? 1.1 : 1.0)
                    .rotationEffect(.degrees(rotate))
            }
            
            VStack(spacing: 16) {
                Text("no_favorites".localized)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Text("add_favorites_message".localized)
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
                .linear(duration: 15)
                .repeatForever(autoreverses: false)
            ) {
                rotate = 360
            }
        }
    }
}

#Preview {
    FavoritesView(viewModel: OrderViewModel())
}
