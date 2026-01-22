import SwiftUI

struct EditOrderView: View {
    @ObservedObject var viewModel: OrderViewModel
    @Environment(\.dismiss) var dismiss
    @State private var selectedCategory: MenuCategory = .foods
    @Namespace private var categoryNamespace
    
    var body: some View {
        NavigationView {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(MenuCategory.allCases) { category in
                                let isSelected = selectedCategory == category
                                let itemCount = viewModel.getMenuItems(for: category).count
                                
                                FloatingCategoryPill(
                                    category: category,
                                    isSelected: isSelected,
                                    itemCount: itemCount,
                                    namespace: categoryNamespace
                                ) {
                                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                    impactFeedback.impactOccurred()
                                    
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 16)
                    .background(AppTheme.cardBackground.opacity(0.8))
                    

                    if !viewModel.orderItems.isEmpty {
                        VStack(spacing: 12) {
                            HStack {
                                Text(LocalizationManager.shared.currentLanguage == .turkish ? "Mevcut Sipariş" : "Current Order")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(AppTheme.brownDark)
                                
                                Spacer()
                                
                                Text("\(viewModel.itemCount) \(viewModel.itemCount == 1 ? "item".localized : "items".localized)")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(AppTheme.brownMedium)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.orderItems) { orderItem in
                                        EditOrderItemCard(orderItem: orderItem, viewModel: viewModel)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.bottom, 16)
                        }
                        .background(AppTheme.beigeLight.opacity(0.5))
                    }
                    

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.getMenuItems(for: selectedCategory)) { item in
                                EditMenuItemCard(item: item, viewModel: viewModel)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 20)
                    }
                    

                    if viewModel.itemCount > 0 {
                        VStack(spacing: 16) {
                            Divider()
                                .background(AppTheme.brownMedium.opacity(0.2))
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("\(viewModel.itemCount) \(viewModel.itemCount == 1 ? "item".localized : "items".localized)")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(AppTheme.brownMedium)
                                    
                                    Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", viewModel.totalPrice))
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(AppTheme.brownDark)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    dismiss()
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                        Text(LocalizationManager.shared.currentLanguage == .turkish ? "Kaydet" : "Save Changes")
                                    }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            colors: [AppTheme.brownDark, AppTheme.brownMedium],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(20)
                                    .shadow(color: AppTheme.brownDark.opacity(0.3), radius: 10, x: 0, y: 4)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.vertical, 16)
                        .background(AppTheme.cardBackground)
                    }
                }
            }
            .navigationTitle(LocalizationManager.shared.currentLanguage == .turkish ? "Siparişi Düzenle" : "Edit Order")
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
}

struct EditOrderItemCard: View {
    let orderItem: OrderItem
    @ObservedObject var viewModel: OrderViewModel
    @State private var removeScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 8) {

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.beigeLight, AppTheme.beigeMedium.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Image(orderItem.menuItem.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
            }
            

            Text(orderItem.menuItem.name)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundColor(AppTheme.brownDark)
                .lineLimit(2)
                .frame(width: 80)
                .multilineTextAlignment(.center)
            

            HStack(spacing: 8) {
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    viewModel.removeItem(orderItem)
                }) {
                    Image(systemName: orderItem.quantity > 1 ? "minus.circle.fill" : "trash.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(orderItem.quantity > 1 ? AppTheme.brownMedium : .red)
                }
                
                Text("\(orderItem.quantity)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .frame(minWidth: 20)
                
                Button(action: {
                    let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                    impactFeedback.impactOccurred()
                    viewModel.addItem(orderItem.menuItem)
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(AppTheme.brownDark)
                }
            }
        }
        .padding(12)
        .background(AppTheme.cardBackground)
        .cornerRadius(16)
        .shadow(color: AppTheme.brownDark.opacity(0.06), radius: 6, x: 0, y: 3)
        .scaleEffect(removeScale)
    }
}

struct EditMenuItemCard: View {
    let item: MenuItem
    @ObservedObject var viewModel: OrderViewModel
    @State private var addScale: CGFloat = 1.0
    
    private var itemQuantity: Int {
        viewModel.orderItems.first(where: { $0.menuItem.id == item.id })?.quantity ?? 0
    }
    
    var body: some View {
        HStack(spacing: 16) {

            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [AppTheme.beigeLight, AppTheme.beigeMedium.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                
                Image(item.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            

            VStack(alignment: .leading, spacing: 6) {
                Text(item.name)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(AppTheme.brownDark)
                    .lineLimit(1)
                
                Text(String(format: LocalizationManager.shared.currentLanguage == .turkish ? "%.2f ₺" : "$%.2f", item.price))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(AppTheme.brownMedium)
                
                if itemQuantity > 0 {
                    Text("\(itemQuantity) \("item".localized) \(LocalizationManager.shared.currentLanguage == .turkish ? "sepetinde" : "in cart")")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(AppTheme.brownMedium)
                }
            }
            
            Spacer()
            

            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                    addScale = 1.2
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        addScale = 1.0
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
                    
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .scaleEffect(addScale)
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(AppTheme.cardBackground)
        .cornerRadius(20)
        .shadow(color: AppTheme.brownDark.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

#Preview {
    EditOrderView(viewModel: OrderViewModel())
}
