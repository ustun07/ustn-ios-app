import SwiftUI

struct OrderHistoryView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var scrollOffset: CGFloat = 0
    @State private var animateIn = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                // Floating orbs
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                if viewModel.orderHistory.isEmpty {
                    EmptyOrderHistoryView()
                } else {
                    GeometryReader { geometry in
                        ScrollView {
                            VStack(spacing: 0) {
                                // Hero section
                                OrderHistoryHeroSection(
                                    orderCount: viewModel.orderHistory.count,
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
                                
                                // History cards
                                LazyVStack(spacing: 20) {
                                    ForEach(Array(viewModel.orderHistory.enumerated()), id: \.element.id) { index, historyItem in
                                        ModernOrderHistoryCard(historyItem: historyItem)
                                            .opacity(animateIn ? 1 : 0)
                                            .offset(y: animateIn ? 0 : 40)
                                            .animation(
                                                .spring(response: 0.7, dampingFraction: 0.75)
                                                .delay(Double(index) * 0.1),
                                                value: animateIn
                                            )
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
            .navigationTitle("order_history".localized)
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

// MARK: - Order History Hero Section
struct OrderHistoryHeroSection: View {
    let orderCount: Int
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
                Text("📋")
                    .font(.system(size: 80))
                    .offset(y: parallaxOffset)
                    .scaleEffect(1 + parallaxOffset / 1000)
                    .rotationEffect(.degrees(parallaxOffset * 0.1))
                
                VStack(spacing: 8) {
                    Text("\(orderCount) \(LocalizationManager.shared.currentLanguage == .turkish ? "sipariş" : "orders")")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("order_history".localized)
                        .font(.system(size: 18, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
                .offset(y: parallaxOffset * 0.3)
            }
        }
    }
}

// MARK: - Modern Order History Card
struct ModernOrderHistoryCard: View {
    let historyItem: OrderHistoryItem
    @State private var cardScale: CGFloat = 1.0
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: LocalizationManager.shared.currentLanguage == .turkish ? "tr_TR" : "en_US")
        return formatter.string(from: historyItem.date)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(AppTheme.brownMedium)
                        
                        Text(LocalizationManager.shared.currentLanguage == .turkish ? "Masa \(historyItem.table.number)" : "Table \(historyItem.table.number)")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                    }
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 14))
                            .foregroundColor(AppTheme.brownMedium)
                        
                        Text(formattedDate)
                            .font(.system(size: 15, design: .rounded))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", historyItem.totalPrice))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Text("\(historyItem.items.count) \(historyItem.items.count == 1 ? "item".localized : "items".localized)")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
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
            
            // Items list
            VStack(spacing: 12) {
                ForEach(historyItem.items) { orderItem in
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            AppTheme.beigeMedium.opacity(0.6),
                                            AppTheme.beigeLight.opacity(0.8)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            
                            Image(orderItem.menuItem.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 28, height: 28)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(orderItem.menuItem.name)
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                                .lineLimit(1)
                            
                            Text(orderItem.menuItem.category.localizedName)
                                .font(.system(size: 13, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                        }
                        
                        Spacer()
                        
                        HStack(spacing: 8) {
                            Text("\(orderItem.quantity)x")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(AppTheme.beigeMedium.opacity(0.3))
                                )
                            
                            Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", orderItem.totalPrice))
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            
            // Notes section
            if !historyItem.notes.isEmpty {
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
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "note.text")
                        .font(.system(size: 16))
                        .foregroundColor(AppTheme.brownMedium)
                        .frame(width: 24)
                    
                    Text(historyItem.notes)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppTheme.beigeMedium.opacity(0.2))
                )
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
        .onTapGesture {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                cardScale = 0.98
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    cardScale = 1.0
                }
            }
        }
    }
}

// MARK: - Empty Order History View
struct EmptyOrderHistoryView: View {
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
                
                Text("📋")
                    .font(.system(size: 100))
                    .scaleEffect(animateEmoji ? 1.1 : 1.0)
                    .rotationEffect(.degrees(rotate))
            }
            
            VStack(spacing: 16) {
                Text("no_order_history".localized)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Text("no_order_history_message".localized)
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
    OrderHistoryView(viewModel: OrderViewModel())
}
