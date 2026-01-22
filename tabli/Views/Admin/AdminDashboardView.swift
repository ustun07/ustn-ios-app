import SwiftUI

struct AdminDashboardView: View {
    @EnvironmentObject var orderViewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                AnimatedGradientBackground()
                    .ignoresSafeArea()
                
                FloatingOrbsView()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Stats
                        HStack(spacing: 16) {
                            AdminStatCard(
                                icon: "clock.fill",
                                value: "\(orderViewModel.orderHistory.filter { _ in orderViewModel.orderStatus == .pending }.count > 0 ? 1 : 0)",
                                label: "Bekleyen",
                                color: .orange
                            )
                            
                            AdminStatCard(
                                icon: "flame.fill",
                                value: "\(orderViewModel.orderStatus == .preparing ? 1 : 0)",
                                label: "Hazırlanan",
                                color: AppTheme.brownMedium
                            )
                            
                            AdminStatCard(
                                icon: "checkmark.circle.fill",
                                value: "\(orderViewModel.orderStatus == .ready ? 1 : 0)",
                                label: "Hazır",
                                color: .green
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // Active Order Section
                        if orderViewModel.orderStatus != .none {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Aktif Sipariş")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                    .padding(.horizontal, 20)
                                
                                ActiveOrderCard(orderViewModel: orderViewModel)
                                    .padding(.horizontal, 20)
                            }
                        } else {
                            // Empty State
                            VStack(spacing: 20) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(AppTheme.brownMedium.opacity(0.5))
                                
                                Text("Aktif sipariş bulunmuyor")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(AppTheme.brownMedium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        }
                        
                        // Recent Orders
                        if !orderViewModel.orderHistory.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Son Siparişler")
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                    .padding(.horizontal, 20)
                                
                                ForEach(orderViewModel.orderHistory.prefix(5)) { order in
                                    OrderHistoryCard(order: order)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Yönetici Paneli")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Çıkış")
                        }
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Admin Stat Card
struct AdminStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
            
            Text(label)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
        )
    }
}

// MARK: - Active Order Card
struct ActiveOrderCard: View {
    @ObservedObject var orderViewModel: OrderViewModel
    
    var statusColor: Color {
        switch orderViewModel.orderStatus {
        case .pending: return .orange
        case .preparing: return AppTheme.brownMedium
        case .ready: return .green
        case .completed: return .blue
        case .none: return .gray
        }
    }
    
    var statusText: String {
        switch orderViewModel.orderStatus {
        case .pending: return "Bekliyor"
        case .preparing: return "Hazırlanıyor"
        case .ready: return "Hazır"
        case .completed: return "Tamamlandı"
        case .none: return ""
        }
    }
    
    var statusDescription: String {
        switch orderViewModel.orderStatus {
        case .pending: return "Müşteri siparişi onay bekliyor."
        case .preparing: return "Sipariş mutfakta hazırlanıyor."
        case .ready: return "Sipariş teslime hazır."
        case .completed: return "Sipariş teslim edildi."
        case .none: return ""
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                if let table = orderViewModel.currentTable {
                    HStack(spacing: 8) {
                        DiningTableIcon(size: 20, color: AppTheme.brownDark)
                        Text("Masa \(table.number)")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                    .foregroundColor(AppTheme.brownDark)
                }
                
                Spacer()
                
                // Status Badge
                Text(statusText)
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(statusColor)
                    )
            }
            
            // Status Description
            Text(statusDescription)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppTheme.brownMedium)
            
            Divider()
            
            // Order Items
            ForEach(orderViewModel.orderItems) { item in
                HStack {
                    Text("\(item.quantity)x")
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                        .frame(width: 30)
                    
                    Text(item.menuItem.name)
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                    
                    Spacer()
                    
                    Text(String(format: "₺%.2f", item.totalPrice))
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.brownDark)
                }
            }
            
            Divider()
            
            // Total
            HStack {
                Text("Toplam")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Spacer()
                
                Text(String(format: "₺%.2f", orderViewModel.totalPrice))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
            }
            
            // Action Buttons
            HStack(spacing: 12) {
                if orderViewModel.orderStatus == .pending {
                    Button(action: {
                        withAnimation {
                            orderViewModel.approveOrder()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Onayla")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                }
                
                if orderViewModel.orderStatus == .preparing {
                    Button(action: {
                        withAnimation {
                            orderViewModel.completeOrder()
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "tray.and.arrow.up.fill")
                            Text("Hazır")
                        }
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: AppTheme.brownDark.opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(statusColor.opacity(0.4), lineWidth: 2)
        )
    }
}

// MARK: - Order History Card
struct OrderHistoryCard: View {
    let order: OrderHistoryItem
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter.string(from: order.date)
    }
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(AppTheme.brownMedium.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                DiningTableIcon(size: 22, color: AppTheme.brownMedium)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Masa \(order.table.number)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                
                Text("\(order.items.count) ürün · \(formattedDate)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
            }
            
            Spacer()
            
            Text(String(format: "₺%.2f", order.totalPrice))
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(AppTheme.brownMedium.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Seed Demo Users Button
struct SeedDemoUsersButton: View {
    @StateObject private var profileViewModel = UserProfileViewModel()
    @State private var isLoading = false
    @State private var showSuccess = false
    @State private var showError = false
    
    var body: some View {
        Button(action: {
            isLoading = true
            Task {
                await profileViewModel.seedDemoUsers()
                isLoading = false
                showSuccess = true
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Image(systemName: showSuccess ? "checkmark.circle.fill" : "person.3.fill")
                        .font(.system(size: 20))
                }
                
                Text(showSuccess ? "Kullanıcılar Oluşturuldu!" : "Demo Kullanıcıları Oluştur")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: showSuccess ? [.green, .green.opacity(0.8)] : [AppTheme.brownDark, AppTheme.brownMedium],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .disabled(isLoading || showSuccess)
    }
}

#Preview {
    AdminDashboardView()
        .environmentObject(OrderViewModel())
}
