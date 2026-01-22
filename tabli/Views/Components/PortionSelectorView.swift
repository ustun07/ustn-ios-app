import SwiftUI

// MARK: - Portion Selector View
// Yiyecekler için porsiyon seçimi
struct PortionSelectorView: View {
    let orderItem: OrderItem
    @ObservedObject var viewModel: OrderViewModel
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(PortionSize.allCases) { portion in
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    viewModel.updatePortionSize(for: orderItem, to: portion)
                }) {
                    Text(portionLabel(portion))
                        .font(.system(size: 10, weight: orderItem.portionSize == portion ? .bold : .medium, design: .rounded))
                        .foregroundColor(orderItem.portionSize == portion ? .white : AppTheme.brownDark)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(
                                    orderItem.portionSize == portion ?
                                    LinearGradient(
                                        colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [AppTheme.beigeMedium.opacity(0.5), AppTheme.beigeMedium.opacity(0.3)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                        .overlay(
                            Capsule()
                                .stroke(
                                    orderItem.portionSize == portion ?
                                    Color.white.opacity(0.3) :
                                    AppTheme.brownMedium.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }
            }
        }
    }
    
    // Kısa etiketler
    private func portionLabel(_ portion: PortionSize) -> String {
        switch portion {
        case .normal: return "1x"
        case .birBucuk: return "1.5x"
        case .duble: return "2x"
        }
    }
}

#Preview {
    let viewModel = OrderViewModel()
    let menuItem = MenuItem(
        name: "Test",
        description: "Test",
        price: 100,
        imageName: "iskender",
        category: .foods
    )
    let orderItem = OrderItem(menuItem: menuItem, quantity: 1, portionSize: .normal)
    
    return PortionSelectorView(orderItem: orderItem, viewModel: viewModel)
        .padding()
}
