import SwiftUI
import UIKit

struct MenuView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    var onOrderComplete: (() -> Void)?
    @State private var selectedCategory: MenuCategory = .foods
    @State private var animateIn = false
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @State private var showProfile = false
    @State private var scrollOffset: CGFloat = 0
    @State private var categoryOffset: CGFloat = 0
    @Namespace private var categoryNamespace
    @Namespace private var itemNamespace
    
    init(viewModel: OrderViewModel, onOrderComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onOrderComplete = onOrderComplete
    }
    
    var filteredItems: [MenuItem] {
        let categoryItems = viewModel.getMenuItems(for: selectedCategory)
        if searchText.isEmpty {
            return categoryItems
        }
        return categoryItems.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
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
                
                GeometryReader { geometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Hero section with parallax
                            HeroSectionView(
                                category: selectedCategory,
                                itemCount: filteredItems.count,
                                scrollOffset: scrollOffset
                            )
                            .frame(height: 280)
                            .background(
                                GeometryReader { geo in
                                    Color.clear.preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: geo.frame(in: .named("scroll")).minY
                                    )
                                }
                            )
                            
                            // Floating search bar
                            FloatingSearchBar(
                                searchText: $searchText,
                                isSearchFocused: $isSearchFocused
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, -20)
                            .zIndex(10)
                            
                            // Category pills
                            FloatingCategoryPills(
                                selectedCategory: $selectedCategory,
                                viewModel: viewModel,
                                namespace: categoryNamespace
                            )
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Products grid with card stack effect
                            if filteredItems.isEmpty {
                                EmptyStateView(searchText: searchText)
                                    .frame(height: 400)
                            } else {
                                StaggeredProductGrid(
                                    items: filteredItems,
                                    viewModel: viewModel,
                                    namespace: itemNamespace,
                                    animateIn: animateIn
                                )
                                .padding(.horizontal, 20)
                                .padding(.top, 30)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                    }
                }
                
                // Floating cart button
                VStack {
                    Spacer()
                    if viewModel.itemCount > 0 {
                        FloatingCartButton(
                            viewModel: viewModel,
                            onOrderComplete: {
                                onOrderComplete?()
                                dismiss()
                            }
                        )
                        .padding(.bottom, 30)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if isSearchFocused {
                    ToolbarItem(placement: .keyboard) {
                        HStack {
                            Spacer()
                            Button(action: {
                                isSearchFocused = false
                            }) {
                                Text(LocalizationManager.shared.currentLanguage == .turkish ? "Kapat" : "Done")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                            }
                        }
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                }
                
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
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: CartView(viewModel: viewModel) {
                        onOrderComplete?()
                        dismiss()
                    }
                        .environmentObject(profileViewModel)
                    ) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 18))
                                .foregroundColor(AppTheme.brownDark)
                            
                            if viewModel.itemCount > 0 {
                                Text(viewModel.itemCount > 99 ? "99+" : "\(viewModel.itemCount)")
                                    .font(.system(size: 8, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .frame(minWidth: viewModel.itemCount > 99 ? 20 : 16, minHeight: 16)
                                    .padding(.horizontal, viewModel.itemCount > 99 ? 3 : 2)
                                    .padding(.vertical, 2)
                                    .background(
                                        Capsule()
                                            .fill(AppTheme.brownDark)
                                    )
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white, lineWidth: 1.5)
                                    )
                                    .offset(x: 6, y: -6)
                            }
                        }
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateIn = true
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView(
                    profileViewModel: profileViewModel,
                    orderViewModel: viewModel
                )
            }
        }
    }
}

// MARK: - Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            colors: [
                Color(hex: "F9F6F2"),
                Color(hex: "F5F1EB"),
                Color(hex: "EDE0D4"),
                Color(hex: "E8D5C4"),
                Color(hex: "DDB892")
            ],
            startPoint: animateGradient ? .topLeading : .bottomTrailing,
            endPoint: animateGradient ? .bottomTrailing : .topLeading
        )
        .hueRotation(.degrees(animateGradient ? 10 : -10))
        .animation(
            .easeInOut(duration: 8)
            .repeatForever(autoreverses: true),
            value: animateGradient
        )
        .onAppear {
            animateGradient = true
        }
    }
}

// MARK: - Floating Orbs
struct FloatingOrbsView: View {
    @State private var orb1Offset: CGSize = .zero
    @State private var orb2Offset: CGSize = .zero
    @State private var orb3Offset: CGSize = .zero
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.brownMedium.opacity(0.15),
                            AppTheme.brownMedium.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .offset(orb1Offset)
                .blur(radius: 30)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.brownDark.opacity(0.12),
                            AppTheme.brownDark.opacity(0.03),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 15,
                        endRadius: 80
                    )
                )
                .frame(width: 150, height: 150)
                .offset(orb2Offset)
                .blur(radius: 25)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            AppTheme.beigeMedium.opacity(0.2),
                            AppTheme.beigeMedium.opacity(0.05),
                            Color.clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 60
                    )
                )
                .frame(width: 120, height: 120)
                .offset(orb3Offset)
                .blur(radius: 20)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                orb1Offset = CGSize(width: 100, height: 150)
            }
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true).delay(0.5)) {
                orb2Offset = CGSize(width: -120, height: 100)
            }
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true).delay(1)) {
                orb3Offset = CGSize(width: 80, height: -130)
            }
        }
    }
}

// MARK: - Hero Section with Parallax
struct HeroSectionView: View {
    let category: MenuCategory
    let itemCount: Int
    let scrollOffset: CGFloat
    
    var parallaxOffset: CGFloat {
        scrollOffset * 0.5
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    AppTheme.brownDark.opacity(0.3),
                    AppTheme.brownMedium.opacity(0.2),
                    AppTheme.beigeMedium.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Content
            VStack(spacing: 20) {
                Text(category.icon)
                    .font(.system(size: 80))
                    .offset(y: parallaxOffset)
                    .scaleEffect(1 + parallaxOffset / 1000)
                
                VStack(spacing: 8) {
                    Text(category.localizedName)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("\(itemCount) \(LocalizationManager.shared.currentLanguage == .turkish ? "ürün" : "items")")
                        .font(.system(size: 16, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                }
                .offset(y: parallaxOffset * 0.3)
            }
        }
    }
}

// MARK: - Floating Search Bar
struct FloatingSearchBar: View {
    @Binding var searchText: String
    @FocusState.Binding var isSearchFocused: Bool
    @State private var isVisible = false
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.brownMedium)
                .font(.system(size: 18))
            
            TextField("search".localized, text: $searchText)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
                .focused($isSearchFocused)
                .submitLabel(.search)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                    isSearchFocused = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppTheme.brownMedium)
                        .font(.system(size: 18))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
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
                            AppTheme.brownMedium.opacity(0.3),
                            AppTheme.brownMedium.opacity(0.1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .scaleEffect(isVisible ? 1 : 0.9)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.2)) {
                isVisible = true
            }
        }
    }
}

// MARK: - Floating Category Pills
struct FloatingCategoryPills: View {
    @Binding var selectedCategory: MenuCategory
    @ObservedObject var viewModel: OrderViewModel
    let namespace: Namespace.ID
    @State private var animateIn = false
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(MenuCategory.allCases.enumerated()), id: \.element.id) { index, category in
                    FloatingCategoryPill(
                        category: category,
                        isSelected: selectedCategory == category,
                        itemCount: viewModel.getMenuItems(for: category).count,
                        namespace: namespace
                    ) {
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            selectedCategory = category
                        }
                    }
                    .opacity(animateIn ? 1 : 0)
                    .offset(x: animateIn ? 0 : 50)
                    .animation(
                        .spring(response: 0.5, dampingFraction: 0.7)
                        .delay(Double(index) * 0.08),
                        value: animateIn
                    )
                }
            }
            .padding(.horizontal, 4)
        }
        .onAppear {
            animateIn = true
        }
    }
}

struct FloatingCategoryPill: View {
    let category: MenuCategory
    let isSelected: Bool
    let itemCount: Int
    let namespace: Namespace.ID
    let action: () -> Void
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                scale = 0.9
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    scale = 1.0
                }
            }
            action()
        }) {
            HStack(spacing: 10) {
                Text(category.icon)
                    .font(.system(size: 20))
                
                Text(category.localizedName)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(isSelected ? .white : AppTheme.brownDark)
                
                if itemCount > 0 {
                    Text("\(itemCount)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : AppTheme.brownMedium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(isSelected ? Color.white.opacity(0.25) : AppTheme.beigeMedium.opacity(0.4))
                        )
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                Group {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .matchedGeometryEffect(id: "selectedCategory", in: namespace)
                            .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 12, x: 0, y: 6)
                    } else {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    }
                }
            )
            .overlay(
                Capsule()
                    .stroke(
                        isSelected ?
                        Color.white.opacity(0.3) :
                        AppTheme.brownMedium.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(scale)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Staggered Product Grid
struct StaggeredProductGrid: View {
    let items: [MenuItem]
    @ObservedObject var viewModel: OrderViewModel
    let namespace: Namespace.ID
    let animateIn: Bool
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                NavigationLink(destination: ProductDetailView(item: item, viewModel: viewModel)) {
                    ModernProductCard(
                        item: item,
                        viewModel: viewModel,
                        namespace: namespace
                    )
                }
                .buttonStyle(.plain)
                .opacity(animateIn ? 1 : 0)
                .offset(y: animateIn ? 0 : 50)
                .animation(
                    .spring(response: 0.6, dampingFraction: 0.75)
                    .delay(Double(index) * 0.06),
                    value: animateIn
                )
            }
        }
    }
}

// MARK: - Modern Product Card
struct ModernProductCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: OrderViewModel
    let namespace: Namespace.ID
    @State private var cardScale: CGFloat = 1.0
    @State private var imageScale: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    private var itemQuantity: Int {
        viewModel.orderItems.first(where: { $0.menuItem.id == item.id })?.quantity ?? 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image section with 3D effect
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.beigeLight,
                                AppTheme.beigeMedium.opacity(0.6),
                                AppTheme.brownMedium.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 180)
                
                // Product image (custom asset)
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .scaleEffect(imageScale)
                    .rotation3DEffect(
                        .degrees(rotation),
                        axis: (x: 0, y: 1, z: 0)
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
                                
                                Image(systemName: viewModel.isFavorite(item) ? "heart.fill" : "heart")
                                    .font(.system(size: 16))
                                    .foregroundColor(viewModel.isFavorite(item) ? .red : AppTheme.brownMedium)
                            }
                        }
                        .padding(12)
                    }
                    Spacer()
                }
                
                // Quantity badge
                if itemQuantity > 0 {
                    VStack {
                        HStack {
                            ZStack {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: 50, height: 28)
                                
                                Text("\(itemQuantity)")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            Spacer()
                        }
                        .padding(12)
                        Spacer()
                    }
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
            VStack(alignment: .leading, spacing: 10) {
                Text(item.name)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", item.price))
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Spacer()
                    
                    if itemQuantity > 0 {
                        HStack(spacing: 8) {
                            Button(action: {
                                if let orderItem = viewModel.orderItems.first(where: { $0.menuItem.id == item.id }) {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    viewModel.removeItem(orderItem)
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.brownMedium)
                            }
                            
                            Button(action: {
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
                                viewModel.addItem(item)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(AppTheme.brownDark)
                            }
                        }
                    } else {
                        Button(action: {
                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                            impactFeedback.impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                cardScale = 0.95
                                imageScale = 1.2
                                rotation = 5
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    cardScale = 1.0
                                    imageScale = 1.0
                                    rotation = 0
                                }
                            }
                            
                            viewModel.addItem(item)
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
                                    .frame(width: 44, height: 44)
                                    .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "plus")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.white)
                            }
                        }
                    }
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
        .rotation3DEffect(
            .degrees(cardScale < 1 ? -5 : 0),
            axis: (x: 1, y: 0, z: 0),
            perspective: 0.5
        )
        .contextMenu {
            Button(action: {
                viewModel.addItem(item)
            }) {
                Label("add_to_cart".localized, systemImage: "cart.badge.plus")
            }
            
            Button(action: {
                viewModel.toggleFavorite(item)
            }) {
                Label(
                    viewModel.isFavorite(item) ? "remove_from_favorites".localized : "add_to_favorites".localized,
                    systemImage: viewModel.isFavorite(item) ? "heart.slash.fill" : "heart.fill"
                )
            }
        }
    }
}

// MARK: - Empty State
struct EmptyStateView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text("🔍")
                .font(.system(size: 80))
                .scaleEffect(1.2)
            
            VStack(spacing: 12) {
                Text("no_items_found".localized)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Text(searchText.isEmpty ? "select_category".localized : "try_different_search".localized)
                    .font(.system(size: 16, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Floating Cart Button
struct FloatingCartButton: View {
    @ObservedObject var viewModel: OrderViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    let onOrderComplete: () -> Void
    @State private var pulseScale: CGFloat = 1.0
    
    var body: some View {
        NavigationLink(destination: CartView(viewModel: viewModel) {
            onOrderComplete()
        }
            .environmentObject(profileViewModel)
        ) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "cart.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                    
                    if viewModel.itemCount > 0 {
                        Text(viewModel.itemCount > 99 ? "99+" : "\(viewModel.itemCount)")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(
                                Capsule()
                                    .fill(Color.red)
                            )
                            .offset(x: 18, y: -18)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(viewModel.itemCount) \(LocalizationManager.shared.currentLanguage == .turkish ? "ürün" : "items")")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                    
                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", viewModel.totalPrice))
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right.circle.fill")
                    .font(.system(size: 28))
                    .foregroundColor(.white)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: AppTheme.brownDark.opacity(0.5), radius: 25, x: 0, y: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
            )
            .scaleEffect(pulseScale)
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.03
            }
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

#Preview {
    MenuView(viewModel: OrderViewModel())
}
