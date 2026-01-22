import SwiftUI

struct OrderConfirmationView: View {
    @ObservedObject var viewModel: OrderViewModel
    @ObservedObject var localizationManager = LocalizationManager.shared
    @Environment(\.dismiss) var dismiss
    var onComplete: (() -> Void)?
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkRotation: Double = 0
    @State private var ringScale: CGFloat = 0
    @State private var confettiEnabled = true
    @State private var messageOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -200
    @State private var glowOpacity: Double = 0
    @State private var showOrderStatus = false
    
    init(viewModel: OrderViewModel, onComplete: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onComplete = onComplete
    }
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
            
            // Floating orbs
            FloatingOrbsView()
                .ignoresSafeArea()
            
            // Confetti
            if confettiEnabled {
                ModernConfettiView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 50) {
                Spacer()
                
                // Animated checkmark with effects
                ZStack {
                    // Outer glow rings
                    ForEach(0..<3) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.green.opacity(0.6),
                                        Color.green.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: 220 + CGFloat(index * 40), height: 220 + CGFloat(index * 40))
                            .scaleEffect(ringScale)
                            .opacity(glowOpacity * (1.0 - Double(index) * 0.3))
                            .animation(
                                .easeOut(duration: 1.5)
                                .delay(Double(index) * 0.2),
                                value: ringScale
                            )
                    }
                    
                    // Main circle with gradient
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.green.opacity(0.3),
                                    Color.green.opacity(0.15),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .scaleEffect(checkmarkScale * 1.3)
                        .opacity(glowOpacity * 0.6)
                    
                    // Glassmorphism circle
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.black.opacity(0.2), radius: 30, x: 0, y: 15)
                    
                    // Checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 100))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(checkmarkScale)
                        .rotationEffect(.degrees(checkmarkRotation))
                        .shadow(color: Color.green.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                
                // Message section
                VStack(spacing: 20) {
                    Text("order_placed".localized)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                        .opacity(messageOpacity)
                    
                    Text("order_sent_message".localized)
                        .font(.system(size: 20, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .lineSpacing(6)
                        .opacity(messageOpacity)
                }
                .opacity(messageOpacity)
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 16) {
                    Button(action: {
                        showOrderStatus = true
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(.ultraThinMaterial)
                                .frame(height: 64)
                                .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                            
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
                            
                            HStack(spacing: 14) {
                                Image(systemName: "list.bullet")
                                    .font(.system(size: 22))
                                
                                Text(LocalizationManager.shared.currentLanguage == .turkish ? "Siparişi Görüntüle" : "View Order")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(AppTheme.brownDark)
                            .padding(.horizontal, 28)
                        }
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
                    }
                    .opacity(messageOpacity)
                    
                    Button(action: {
                        viewModel.clearCart()
                        dismiss()
                        onComplete?()
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
                            
                            HStack(spacing: 14) {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 22))
                                
                                Text("back_to_home".localized)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 28)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1.5)
                        )
                    }
                    .opacity(messageOpacity)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Checkmark animation
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                checkmarkScale = 1.0
                checkmarkRotation = 360
            }
            
            // Ring expansion
            withAnimation(.easeOut(duration: 1.5)) {
                ringScale = 1.2
                glowOpacity = 1.0
            }
            
            // Message fade in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeIn(duration: 0.6)) {
                    messageOpacity = 1.0
                }
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                shimmerOffset = 400
            }
            
            // Confetti fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation(.easeOut(duration: 1.0)) {
                    confettiEnabled = false
                }
            }
            
            // Success feedback
            let successFeedback = UINotificationFeedbackGenerator()
            successFeedback.notificationOccurred(.success)
        }
        .sheet(isPresented: $showOrderStatus) {
            OrderStatusView(viewModel: viewModel)
        }
    }
}

// MARK: - Modern Confetti View
struct ModernConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    struct ConfettiParticle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var color: Color
        var rotation: Double
        var velocity: CGSize
        var size: CGFloat
        var opacity: Double
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color.opacity(particle.opacity))
                        .frame(width: particle.size, height: particle.size)
                        .position(x: particle.x, y: particle.y)
                        .rotationEffect(.degrees(particle.rotation))
                }
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        let colors: [Color] = [
            AppTheme.brownDark,
            AppTheme.brownMedium,
            AppTheme.beigeMedium,
            Color.green,
            Color.orange,
            AppTheme.beigeLight
        ]
        
        particles = (0..<80).map { _ in
            ConfettiParticle(
                x: UIScreen.main.bounds.width / 2,
                y: UIScreen.main.bounds.height / 2,
                color: colors.randomElement() ?? AppTheme.brownDark,
                rotation: Double.random(in: 0...360),
                velocity: CGSize(
                    width: CGFloat.random(in: -250...250),
                    height: CGFloat.random(in: (-400)...(-150))
                ),
                size: CGFloat.random(in: 6...14),
                opacity: Double.random(in: 0.6...1.0)
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeOut(duration: 3.0)) {
            for i in particles.indices {
                particles[i].x += particles[i].velocity.width
                particles[i].y += particles[i].velocity.height
                particles[i].rotation += Double.random(in: 180...720)
                particles[i].opacity *= 0.95
            }
        }
    }
}

#Preview {
    OrderConfirmationView(viewModel: OrderViewModel())
}
