import SwiftUI

struct ContentView: View {
    @ObservedObject var appViewModel: AppViewModel // ✅ これが StateObject か？

    var body: some View {
        Group {
            switch appViewModel.currentScreen {
            case .loading:
                ProgressView("読み込み中...")
            case .trackingDenied:
                Text("トラッキングが拒否されました")
            case .auth:
                AuthenticationView(viewModel: appViewModel.authViewModel)
            case .main(let viewModel):
                MainView(viewModel: viewModel)
            }
        }
        .onAppear {
            appViewModel.start()
        }
    }
}

