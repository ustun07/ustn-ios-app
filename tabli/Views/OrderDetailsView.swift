import SwiftUI

struct OrderDetailsView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                if viewModel.orderItems.isEmpty {
                    VStack(spacing: 24) {
                        Text("📋")
                            .font(.system(size: 80))
                        Text(LocalizationManager.shared.currentLanguage == .turkish ? "Sipariş bulunamadı" : "No order found")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(AppTheme.brownDark)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {

                            VStack(spacing: 16) {
                                if let table = viewModel.currentTable {
                                    HStack {
                                        Text("table".localized)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(AppTheme.brownMedium)
                                        
                                        Text("\(table.number)")
                                            .font(.system(size: 32, weight: .bold, design: .rounded))
                                            .foregroundColor(AppTheme.brownDark)
                                    }
                                    .padding(.vertical, 16)
                                    .padding(.horizontal, 24)
                                    .background(AppTheme.cardBackground)
                                    .cornerRadius(20)
                                }
                                

                                HStack {
                                    Image(systemName: statusIcon)
                                        .font(.system(size: 18))
                                        .foregroundColor(statusColor)
                                    
                                    Text(statusTitle)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(statusColor)
                                }
                                .padding(.vertical, 12)
                                .padding(.horizontal, 20)
                                .background(statusColor.opacity(0.1))
                                .cornerRadius(16)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            

                            VStack(spacing: 16) {
                                ForEach(viewModel.orderItems) { orderItem in
                                    OrderDetailItemRow(orderItem: orderItem)
                                }
                            }
                            .padding(.horizontal, 20)
                            

                            VStack(spacing: 12) {
                                Divider()
                                    .background(AppTheme.brownMedium.opacity(0.2))
                                    .padding(.horizontal, 20)
                                
                                HStack {
                                    Text("total".localized)
                                        .font(.system(size: 22, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.brownDark)
                                    
                                    Spacer()
                                    
                                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", viewModel.totalPrice))
                                        .font(.system(size: 28, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.brownDark)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 20)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle(LocalizationManager.shared.currentLanguage == .turkish ? "Sipariş Detayları" : "Order Details")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(AppTheme.brownMedium)
                    }
                }
            }
        }
    }
    
    private var statusIcon: String {
        switch viewModel.orderStatus {
        case .pending: return "clock.fill"
        case .preparing: return "timer"
        case .ready: return "checkmark.circle.fill"
        case .completed: return "hand.thumbsup.fill"
        case .none: return "circle"
        }
    }
    
    private var statusColor: Color {
        switch viewModel.orderStatus {
        case .pending: return AppTheme.brownMedium
        case .preparing: return AppTheme.brownDark
        case .ready: return Color.green
        case .completed: return Color.blue
        case .none: return AppTheme.brownMedium
        }
    }
    
    private var statusTitle: String {
        switch viewModel.orderStatus {
        case .pending: return "order_pending".localized
        case .preparing: return "preparing".localized
        case .ready: return "order_ready".localized
        case .completed: return "order_completed".localized
        case .none: return "no_active_order".localized
        }
    }
}

struct OrderDetailItemRow: View {
    let orderItem: OrderItem
    
    var body: some View {
        HStack(spacing: 16) {

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.beigeLight, AppTheme.beigeMedium.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                    Image(orderItem.menuItem.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45, height: 45)
            }
            

            VStack(alignment: .leading, spacing: 6) {
                Text(orderItem.menuItem.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .lineLimit(1)
                
                Text("\(orderItem.quantity) x \(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", orderItem.menuItem.price))")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
            }
            
            Spacer()
            

            Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", orderItem.totalPrice))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.brownDark.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    OrderDetailsView(viewModel: OrderViewModel())
}
