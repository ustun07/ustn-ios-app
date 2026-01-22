import SwiftUI
import AVFoundation

struct QRCodeScannerView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var isScanning = false
    @State private var scannedCode: String?
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var cameraPermissionDenied = false
    @State private var scanPulse: CGFloat = 1.0
    @State private var scanRotation: Double = 0
    
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
                    // Header section
                    VStack(spacing: 20) {
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
                                        startRadius: 30,
                                        endRadius: 100
                                    )
                                )
                                .frame(width: 160, height: 160)
                                .scaleEffect(scanPulse)
                                .blur(radius: 20)
                            
                            Text("📱")
                                .font(.system(size: 80))
                                .scaleEffect(scanPulse)
                                .rotationEffect(.degrees(scanRotation))
                        }
                        
                        VStack(spacing: 12) {
                            Text("scan_qr_code".localized)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(AppTheme.brownDark)
                            
                            Text(LocalizationManager.shared.currentLanguage == .turkish ?
                                 "Masa üzerindeki QR kodu tarayın" :
                                 "Scan the QR code on your table")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundColor(AppTheme.brownMedium)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                                .lineSpacing(6)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Scanner view
                    ZStack {
                        // Glassmorphism container
                        RoundedRectangle(cornerRadius: 32)
                            .fill(.ultraThinMaterial)
                            .frame(width: 320, height: 320)
                            .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 30, x: 0, y: 15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 32)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                AppTheme.brownDark.opacity(0.4),
                                                AppTheme.brownMedium.opacity(0.3),
                                                AppTheme.brownMedium.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                        
                        // Camera view
                        if !cameraPermissionDenied {
                            QRCodeScannerRepresentable(
                                onQRCodeScanned: { code in
                                    isScanning = false
                                    handleScannedCode(code)
                                },
                                onError: { error in
                                    isScanning = false
                                    errorMessage = error
                                    if error.contains("permission") {
                                        cameraPermissionDenied = true
                                    }
                                    showError = true
                                }
                            )
                            .frame(width: 300, height: 300)
                            .clipShape(RoundedRectangle(cornerRadius: 28))
                            .overlay(
                                ModernScannerCorners()
                                    .frame(width: 300, height: 300)
                            )
                            
                            // Success overlay
                            if !isScanning {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 28)
                                        .fill(Color.black.opacity(0.5))
                                    
                                    VStack(spacing: 16) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.green.opacity(0.3))
                                                .frame(width: 80, height: 80)
                                            
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.system(size: 50))
                                                .foregroundColor(.green)
                                        }
                                        
                                        Text(LocalizationManager.shared.currentLanguage == .turkish ? "QR Kod Tespit Edildi" : "QR Code Detected")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(.white)
                                    }
                                }
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                            }
                        } else {
                            // Permission denied view
                            VStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(AppTheme.brownMedium.opacity(0.2))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(AppTheme.brownMedium)
                                }
                                
                                VStack(spacing: 12) {
                                    Text(LocalizationManager.shared.currentLanguage == .turkish ? "Kamera İzni Gerekli" : "Camera Permission Required")
                                        .font(.system(size: 20, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.brownDark)
                                    
                                    Text(LocalizationManager.shared.currentLanguage == .turkish ?
                                         "QR kod tarayabilmek için kamera erişimine ihtiyacımız var." :
                                         "We need camera access to scan QR codes.")
                                        .font(.system(size: 15, design: .rounded))
                                        .foregroundColor(AppTheme.brownMedium)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, 20)
                                }
                            }
                            .frame(width: 300, height: 300)
                            .background(
                                RoundedRectangle(cornerRadius: 28)
                                    .fill(.ultraThinMaterial)
                            )
                        }
                    }
                    .padding(.vertical, 30)
                    
                    Spacer()
                    
                    // Manual entry button
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 14) {
                            Image(systemName: "hand.tap")
                                .font(.system(size: 20))
                            
                            Text(LocalizationManager.shared.currentLanguage == .turkish ? "Manuel Giriş" : "Manual Entry")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                        }
                        .foregroundColor(AppTheme.brownDark)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 26)
                                .fill(.ultraThinMaterial)
                                .shadow(color: Color.black.opacity(0.1), radius: 15, x: 0, y: 8)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 26)
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
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(LocalizationManager.shared.currentLanguage == .turkish ? "QR Kod" : "QR Code")
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
                isScanning = true
                
                // Pulse animation
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                    scanPulse = 1.1
                }
                
                // Rotation animation
                withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
                    scanRotation = 360
                }
            }
            .alert(isPresented: $showError) {
                Alert(
                    title: Text(LocalizationManager.shared.currentLanguage == .turkish ? "Hata" : "Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text(LocalizationManager.shared.currentLanguage == .turkish ? "Tamam" : "OK"))
                )
            }
        }
    }
    
    private func handleScannedCode(_ code: String) {
        isScanning = false
        
        viewModel.setTableFromQR(code: code)
        
        if viewModel.currentTable != nil {
            let impactFeedback = UINotificationFeedbackGenerator()
            impactFeedback.notificationOccurred(.success)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        } else {
            let impactFeedback = UINotificationFeedbackGenerator()
            impactFeedback.notificationOccurred(.error)
            
            errorMessage = LocalizationManager.shared.currentLanguage == .turkish ?
                "Geçersiz QR kod. Lütfen masa üzerindeki QR kodu tarayın." :
                "Invalid QR code. Please scan the QR code on your table."
            showError = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isScanning = true
            }
        }
    }
}

// MARK: - Modern Scanner Corners
struct ModernScannerCorners: View {
    var body: some View {
        ZStack {
            // Top-left corner
            Path { path in
                path.move(to: CGPoint(x: 20, y: 40))
                path.addLine(to: CGPoint(x: 20, y: 20))
                path.addLine(to: CGPoint(x: 40, y: 20))
            }
            .stroke(
                LinearGradient(
                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 300, height: 300, alignment: .topLeading)
            
            // Top-right corner
            Path { path in
                path.move(to: CGPoint(x: 280, y: 20))
                path.addLine(to: CGPoint(x: 280, y: 40))
                path.addLine(to: CGPoint(x: 260, y: 20))
            }
            .stroke(
                LinearGradient(
                    colors: [AppTheme.brownMedium, AppTheme.brownDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 300, height: 300, alignment: .topTrailing)
            
            // Bottom-left corner
            Path { path in
                path.move(to: CGPoint(x: 20, y: 260))
                path.addLine(to: CGPoint(x: 20, y: 280))
                path.addLine(to: CGPoint(x: 40, y: 280))
            }
            .stroke(
                LinearGradient(
                    colors: [AppTheme.brownMedium, AppTheme.brownDark],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 300, height: 300, alignment: .bottomLeading)
            
            // Bottom-right corner
            Path { path in
                path.move(to: CGPoint(x: 280, y: 280))
                path.addLine(to: CGPoint(x: 280, y: 260))
                path.addLine(to: CGPoint(x: 260, y: 280))
            }
            .stroke(
                LinearGradient(
                    colors: [AppTheme.brownDark, AppTheme.brownMedium],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
            )
            .frame(width: 300, height: 300, alignment: .bottomTrailing)
        }
    }
}

#Preview {
    QRCodeScannerView(viewModel: OrderViewModel())
}
