//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    @StateObject private var viewModel = TrackingAuthorizationViewModel()
    @Environment(\.scenePhase) var scenePhase

    var body: some View {
        Group {
            if viewModel.isTrackingAuthorized == nil {
                EmptyView()
            } else if viewModel.isTrackingAuthorized == true {
                // メイン画面をここに（仮）
                Text("トラッキング許可済み")
            } else {
                trackingDeniedView
            }
        }
        .onAppear {
            viewModel.checkAuthorizationStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                viewModel.checkAuthorizationStatus()
            }
        }
    }

    private var trackingDeniedView: some View {
        VStack {
            Text("トラッキングが拒否されました")
            Button("設定を開く") {
                viewModel.openSettings()
            }
        }
        .padding()
    }
}
