import SwiftUI

// MARK: - Dining Table Icon
// Basit bir yemek masası ve sandalyeler ikonu
struct DiningTableIcon: View {
    var size: CGFloat = 32
    var color: Color = .white
    
    var body: some View {
        ZStack {
            // Table top (masa üstü)
            RoundedRectangle(cornerRadius: size * 0.1)
                .fill(color)
                .frame(width: size * 0.7, height: size * 0.15)
                .offset(y: -size * 0.05)
            
            // Table legs (masa ayakları)
            HStack(spacing: size * 0.35) {
                Rectangle()
                    .fill(color)
                    .frame(width: size * 0.08, height: size * 0.35)
                
                Rectangle()
                    .fill(color)
                    .frame(width: size * 0.08, height: size * 0.35)
            }
            .offset(y: size * 0.15)
            
            // Left chair (sol sandalye)
            VStack(spacing: 0) {
                // Chair back
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(color)
                    .frame(width: size * 0.12, height: size * 0.25)
                
                // Chair seat
                RoundedRectangle(cornerRadius: size * 0.03)
                    .fill(color)
                    .frame(width: size * 0.18, height: size * 0.08)
            }
            .offset(x: -size * 0.45, y: size * 0.02)
            
            // Right chair (sağ sandalye)
            VStack(spacing: 0) {
                // Chair back
                RoundedRectangle(cornerRadius: size * 0.05)
                    .fill(color)
                    .frame(width: size * 0.12, height: size * 0.25)
                
                // Chair seat
                RoundedRectangle(cornerRadius: size * 0.03)
                    .fill(color)
                    .frame(width: size * 0.18, height: size * 0.08)
            }
            .offset(x: size * 0.45, y: size * 0.02)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    ZStack {
        Color.brown
        VStack(spacing: 20) {
            DiningTableIcon(size: 60, color: .white)
            DiningTableIcon(size: 40, color: .black)
            DiningTableIcon(size: 30, color: .orange)
        }
    }
}
