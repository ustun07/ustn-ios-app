import SwiftUI

struct OrderStatusView: View {
    @ObservedObject var viewModel: OrderViewModel
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    @State private var progress: Double = 0.0
    @State private var showOrderDetails = false
    @State private var showEditOrder = false
    @State private var statusScale: CGFloat = 1.0
    @State private var statusRotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var ringScale: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Animated gradient background
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                // Floating orbs
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Status icon with animations
                    ZStack {
                        // Expanding rings
                        ForEach(0..<3) { index in
                            Circle()
                                .stroke(
                                    statusColor.opacity(0.4),
                                    lineWidth: 2
                                )
                                .frame(width: 200 + CGFloat(index * 30), height: 200 + CGFloat(index * 30))
                                .scaleEffect(ringScale)
                                .opacity(1.0 - Double(index) * 0.3)
                        }
                        
                        // Glow effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        statusColor.opacity(0.4),
                                        statusColor.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .scaleEffect(pulseScale)
                        
                        // Glassmorphism circle
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 160, height: 160)
                            .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
                        
                        // Status icon
                        statusIcon
                            .font(.system(size: 70))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [statusColor, statusColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(statusScale)
                            .rotationEffect(.degrees(statusRotation))
                            .shadow(color: statusColor.opacity(0.5), radius: 20, x: 0, y: 10)
                    }
                    
                    // Status text
                    VStack(spacing: 16) {
                        Text(statusTitle)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                        
                        Text(statusMessage)
                            .font(.system(size: 18, design: .rounded))
                            .foregroundColor(AppTheme.brownMedium)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                            .lineSpacing(6)
                    }
                    
                    // Progress indicator
                    if viewModel.orderStatus != .none && viewModel.orderStatus != .ready {
                        ModernProgressView(progress: progress)
                            .padding(.horizontal, 40)
                    }
                    
                    Spacer()
                    
                    // Order summary card
                    if !viewModel.orderItems.isEmpty {
                        ModernOrderSummaryCard(
                            viewModel: viewModel,
                            onViewDetails: {
                                showOrderDetails = true
                            },
                            onEditOrder: {
                                showEditOrder = true
                            },
                            canEdit: viewModel.orderStatus == .pending
                        )
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                    
                    // Table number
                    if let table = viewModel.currentTable {
                        VStack(spacing: 8) {
                            Text("table".localized)
                                .font(.system(size: 18, weight: .medium, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                            
                            Text("\(table.number)")
                                .font(.system(size: 56, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("order_status_title".localized)
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
            .sheet(isPresented: $showOrderDetails) {
                OrderDetailsView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $showEditOrder) {
                EditOrderView(viewModel: viewModel)
            }
            .onAppear {
                updateProgress()
                animateStatus()
            }
            .onChange(of: viewModel.orderStatus) { _ in
                updateProgress()
                animateStatus()
            }
        }
    }
    
    private var statusIcon: Image {
        switch viewModel.orderStatus {
        case .pending:
            return Image(systemName: "clock.fill")
        case .preparing:
            return Image(systemName: "timer")
        case .ready:
            return Image(systemName: "checkmark.circle.fill")
        case .completed:
            return Image(systemName: "hand.thumbsup.fill")
        case .none:
            return Image(systemName: "checkmark.circle.fill")
        }
    }
    
    private var statusColor: Color {
        switch viewModel.orderStatus {
        case .pending:
            return AppTheme.brownMedium
        case .preparing:
            return AppTheme.brownDark
        case .ready:
            return Color.green
        case .completed:
            return Color.blue
        case .none:
            return AppTheme.brownDark
        }
    }
    
    private var statusTitle: String {
        switch viewModel.orderStatus {
        case .pending:
            return "order_pending".localized
        case .preparing:
            return "preparing".localized
        case .ready:
            return "order_ready".localized
        case .completed:
            return "order_completed".localized
        case .none:
            return "no_active_order".localized
        }
    }
    
    private var statusMessage: String {
        switch viewModel.orderStatus {
        case .pending:
            return "order_pending_message".localized
        case .preparing:
            return "preparing_message".localized
        case .ready:
            return "order_ready_message".localized
        case .completed:
            return "order_completed_message".localized
        case .none:
            return "no_order_message".localized
        }
    }
    
    private func updateProgress() {
        withAnimation(.easeInOut(duration: 1.5)) {
            switch viewModel.orderStatus {
            case .pending:
                progress = 0.3
            case .preparing:
                progress = 0.7
            case .ready:
                progress = 1.0
            case .completed:
                progress = 1.0
            case .none:
                progress = 0.0
            }
        }
    }
    
    private func animateStatus() {
        // Scale animation
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            statusScale = 1.2
            statusRotation = 360
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                statusScale = 1.0
                statusRotation = 0
            }
        }
        
        // Ring expansion
        withAnimation(.easeOut(duration: 1.5)) {
            ringScale = 1.3
        }
        
        // Pulse animation
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.15
        }
    }
}

// MARK: - Modern Progress View
struct ModernProgressView: View {
    let progress: Double
    @State private var animatedProgress: Double = 0
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppTheme.brownMedium.opacity(0.2), lineWidth: 1)
                    )
                
                // Progress fill
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.6 * CGFloat(animatedProgress), height: 12)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8), value: animatedProgress)
                
                // Shimmer effect
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: UIScreen.main.bounds.width * 0.6 * CGFloat(animatedProgress), height: 12)
                    .offset(x: CGFloat(animatedProgress) * UIScreen.main.bounds.width * 0.3)
                    .animation(.linear(duration: 2).repeatForever(autoreverses: false), value: animatedProgress)
            }
            
            Text("\(Int(animatedProgress * 100))%")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
        }
        .onChange(of: progress) { newValue in
            animatedProgress = newValue
        }
        .onAppear {
            animatedProgress = progress
        }
    }
}

// MARK: - Modern Order Summary Card
struct ModernOrderSummaryCard: View {
    @ObservedObject var viewModel: OrderViewModel
    let onViewDetails: () -> Void
    let onEditOrder: () -> Void
    let canEdit: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                HStack {
                    Text(LocalizationManager.shared.currentLanguage == .turkish ? "Sipariş Özeti" : "Order Summary")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Spacer()
                    
                    ZStack {
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .frame(height: 32)
                        
                        Text("\(viewModel.itemCount) \(viewModel.itemCount == 1 ? "item".localized : "items".localized)")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                            .padding(.horizontal, 16)
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
                
                HStack {
                    Text("total".localized)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Spacer()
                    
                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", viewModel.totalPrice))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                }
            }
            .padding(24)
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
            
            // Action buttons
            HStack(spacing: 16) {
                Button(action: onViewDetails) {
                    HStack(spacing: 10) {
                        Image(systemName: "list.bullet")
                            .font(.system(size: 18))
                        Text(LocalizationManager.shared.currentLanguage == .turkish ? "Detaylar" : "View Details")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.brownDark)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 22)
                            .fill(.ultraThinMaterial)
                            .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(AppTheme.brownMedium.opacity(0.3), lineWidth: 2)
                    )
                }
                
                if canEdit {
                    Button(action: onEditOrder) {
                        HStack(spacing: 10) {
                            Image(systemName: "pencil")
                                .font(.system(size: 18))
                            Text(LocalizationManager.shared.currentLanguage == .turkish ? "Düzenle" : "Edit Order")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 22)
                                .fill(
                                    LinearGradient(
                                        colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: AppTheme.brownDark.opacity(0.4), radius: 15, x: 0, y: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    OrderStatusView(viewModel: OrderViewModel())
}
