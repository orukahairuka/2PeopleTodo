//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    @State private var isTrackingAuthorized: Bool? = nil  // トラッキング許可の状態（未定義を許可）
    @Environment(\.scenePhase) var scenePhase  // アプリの状態を監視

    var body: some View {
        Group {
            if isTrackingAuthorized == nil {
                ProgressView("トラッキング設定を確認中...")
            } else if isTrackingAuthorized == true {
                AuthenticationView()  // トラッキングが許可された場合
            } else {
                trackingDeniedView  // トラッキングが拒否された場合
            }
        }
        .onAppear {
            checkTrackingAuthorization()  // アプリ起動時にトラッキングの状態を確認
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                checkTrackingAuthorization()  // アプリがアクティブになったときに再確認
            }
        }
    }

    // トラッキング許可の理由を説明するビュー
    private var trackingExplanationView: some View {
        VStack(spacing: 20) {
            Button("続ける") {
                requestTrackingAuthorization()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // トラッキング拒否時のビュー
    private var trackingDeniedView: some View {
        VStack(spacing: 20) {
            
            Button("設定を開く") {
                openSettings()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }

    // トラッキングの許可状態を確認
    private func checkTrackingAuthorization() {
        let status = ATTrackingManager.trackingAuthorizationStatus

        switch status {
        case .authorized:
            isTrackingAuthorized = true
        case .denied, .restricted:
            isTrackingAuthorized = false
        case .notDetermined:
            requestTrackingAuthorization()  // まだ決定されていない場合はリクエストを行う
        @unknown default:
            isTrackingAuthorized = false
        }
    }

    // トラッキング許可のリクエスト
    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    isTrackingAuthorized = true
                case .denied, .restricted:
                    isTrackingAuthorized = false
                case .notDetermined:
                    isTrackingAuthorized = false
                @unknown default:
                    isTrackingAuthorized = false
                }
            }
        }
    }

    // 設定アプリを開く
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
