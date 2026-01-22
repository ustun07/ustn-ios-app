import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: OrderViewModel
    @EnvironmentObject var profileViewModel: UserProfileViewModel
    @State private var showSplash = true
    
    var body: some View {
        Group {
            if showSplash {
                SplashView(showHome: $showSplash)
                    .transition(.opacity)
            } else {
                HomeView(viewModel: viewModel)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: showSplash)
    }
}

#Preview {
    ContentView()
        .environmentObject(OrderViewModel())
        .environmentObject(UserProfileViewModel())
}
