//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()

    var body: some View {
        Group {
            switch appViewModel.currentScreen {
            case .loading:
                ProgressView("読み込み中...")
            case .trackingDenied:
                VStack {
                    Text("トラッキングが拒否されました")
                    Button("設定を開く") {
                        appViewModel.openSettings()
                    }
                }
                .padding()
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
