import SwiftUI


struct SplashView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0
    @State private var logoOffset: CGFloat = 30
    @State private var loadingOpacity: Double = 0
    @State private var backgroundOpacity: Double = 0
    @State private var steamOpacity: Double = 0
    @State private var steamOffset: CGFloat = 0
    @State private var particlesOpacity: Double = 0
    @State private var glowScale: CGFloat = 0
    @State private var glowOpacity: Double = 0
    @Binding var showHome: Bool
    
    var body: some View {
        ZStack {
            // Animated gradient background
            AnimatedGradientBackground()
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Floating orbs
            FloatingOrbsView()
                .ignoresSafeArea()
                .opacity(backgroundOpacity)
            
            // Particle effects
            ParticleEffectView()
                .opacity(particlesOpacity)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                Spacer()
                
                // Logo section with coffee steam
                ZStack {
                    // Expanding glow rings
                    ForEach(0..<4) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        AppTheme.brownMedium.opacity(0.4),
                                        AppTheme.brownMedium.opacity(0.1),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 200 + CGFloat(index * 40), height: 200 + CGFloat(index * 40))
                            .scaleEffect(glowScale)
                            .opacity(glowOpacity * (1.0 - Double(index) * 0.2))
                    }
                    
                    // Main glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.brownMedium.opacity(0.4),
                                    AppTheme.brownMedium.opacity(0.2),
                                    AppTheme.brownMedium.opacity(0.05),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 40,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .scaleEffect(glowScale * 1.2)
                        .opacity(glowOpacity * 0.6)
                        .blur(radius: 30)
                    
                    // Coffee steam particles
                    ForEach(0..<6) { index in
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        AppTheme.brownMedium.opacity(0.5),
                                        AppTheme.brownMedium.opacity(0.2),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 2,
                                    endRadius: 18
                                )
                            )
                            .frame(width: 25 + CGFloat(index * 2), height: 25 + CGFloat(index * 2))
                            .offset(
                                x: CGFloat(index - 3) * 20,
                                y: steamOffset - CGFloat(index * 12) - 100
                            )
                            .opacity(steamOpacity * (1.0 - Double(index) * 0.12))
                            .blur(radius: 8)
                    }
                    
                    // Logo
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 340, height: 340)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                        .offset(y: logoOffset)
                        .shadow(color: AppTheme.brownDark.opacity(0.5), radius: 30, x: 0, y: 15)
                }
                
                Spacer()
                
                // Modern loading indicator
                ModernCoffeeLoadingView()
                    .opacity(loadingOpacity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            // Background fade in
            withAnimation(.easeIn(duration: 0.8)) {
                backgroundOpacity = 1.0
            }
            
            // Glow expansion
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeOut(duration: 1.2)) {
                    glowScale = 1.3
                    glowOpacity = 1.0
                }
            }
            
            // Logo entrance animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    logoScale = 1.0
                    logoOpacity = 1.0
                    logoOffset = 0
                }
            }
            
            // Particles animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                withAnimation(.easeIn(duration: 0.6)) {
                    particlesOpacity = 1.0
                }
            }
            
            // Coffee steam animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 2.5).repeatForever(autoreverses: false)) {
                    steamOffset = -150
                    steamOpacity = 0.9
                }
            }
            
            // Loading indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    loadingOpacity = 1.0
                }
            }
            
            // Exit animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeOut(duration: 0.5)) {
                    logoOpacity = 0
                    loadingOpacity = 0
                    particlesOpacity = 0
                    steamOpacity = 0
                    glowOpacity = 0
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeOut(duration: 0.3)) {
                        backgroundOpacity = 0
                    }
                }
                
                // Transition to home after animations complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    withAnimation {
                        showHome = false
                    }
                }
            }
        }
    }
}

// MARK: - Modern Coffee Loading View
struct ModernCoffeeLoadingView: View {
    @State private var rotation: Double = 0
    @State private var pulseScale: CGFloat = 1.0
    @State private var dotScales: [CGFloat] = [1.0, 1.0, 1.0]
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        VStack(spacing: 24) {
            // Modern circular loader
            ZStack {
                // Outer rotating ring
                Circle()
                    .trim(from: 0, to: 0.8)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.brownDark,
                                AppTheme.brownMedium,
                                AppTheme.beigeMedium.opacity(0.5)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(rotation))
                    .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 10, x: 0, y: 5)
                
                // Inner counter-rotating ring
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppTheme.brownMedium,
                                AppTheme.beigeMedium,
                                AppTheme.beigeLight.opacity(0.5)
                            ],
                            startPoint: .bottomTrailing,
                            endPoint: .topLeading
                        ),
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(-rotation))
                
                // Center pulsing dot
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.brownDark,
                                AppTheme.brownMedium.opacity(0.6)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 8
                        )
                    )
                    .frame(width: 16, height: 16)
                    .scaleEffect(pulseScale)
                    .shadow(color: AppTheme.brownDark.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .overlay(
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                AppTheme.brownMedium.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 60, height: 60)
                    .offset(x: shimmerOffset)
                    .mask(Circle())
            )
            
            // Animated dots
            HStack(spacing: 10) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    AppTheme.brownDark,
                                    AppTheme.brownMedium
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 10, height: 10)
                        .scaleEffect(dotScales[index])
                        .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 5, x: 0, y: 3)
                }
            }
        }
        .onAppear {
            // Rotation animation
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            
            // Pulse animation
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulseScale = 1.4
            }
            
            // Shimmer animation
            withAnimation(.linear(duration: 2.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 200
            }
            
            // Dots animation
            for index in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.15) {
                    withAnimation(
                        .easeInOut(duration: 0.7)
                        .repeatForever(autoreverses: true)
                    ) {
                        dotScales[index] = 1.5
                    }
                }
            }
        }
    }
}

// MARK: - Particle Effect View
struct ParticleEffectView: View {
    @State private var particles: [Particle] = []
    
    struct Particle: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var opacity: Double
        var size: CGFloat
        var velocity: CGSize
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    AppTheme.brownMedium.opacity(particle.opacity),
                                    AppTheme.brownMedium.opacity(particle.opacity * 0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: particle.size
                            )
                        )
                        .frame(width: particle.size * 2, height: particle.size * 2)
                        .position(x: particle.x, y: particle.y)
                }
            }
        }
        .onAppear {
            createParticles()
            animateParticles()
        }
    }
    
    private func createParticles() {
        particles = (0..<30).map { _ in
            Particle(
                x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                y: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                opacity: Double.random(in: 0.3...0.8),
                size: CGFloat.random(in: 3...12),
                velocity: CGSize(
                    width: CGFloat.random(in: -2...2),
                    height: CGFloat.random(in: -3...(-1))
                )
            )
        }
    }
    
    private func animateParticles() {
        withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: true)) {
            for i in particles.indices {
                particles[i].x += particles[i].velocity.width * 10
                particles[i].y += particles[i].velocity.height * 10
                particles[i].opacity = Double.random(in: 0.2...0.7)
            }
        }
    }
}

#Preview {
    SplashView(showHome: .constant(false))
}
