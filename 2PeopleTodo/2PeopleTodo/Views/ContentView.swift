//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    @State private var isTrackingAuthorized = false
    @State private var isCheckingTracking = true
    @State private var showTrackingExplanation = true  // リクエスト前の説明表示用フラグ
    
    var body: some View {
        Group {
            if isCheckingTracking {
                ProgressView("トラッキング設定を確認中...")
            } else if showTrackingExplanation {
                // トラッキング許可前の説明画面
                trackingExplanationView
            } else if !isTrackingAuthorized {
                // トラッキング拒否時のメッセージ
                trackingDeniedView
            } else {
                // トラッキングが許可された場合の画面
                AuthenticationView()
            }
        }
        .onAppear(perform: checkTrackingAuthorization)
    }
    
    // トラッキング許可の理由を説明するビュー
    private var trackingExplanationView: some View {
        VStack(spacing: 20) {
            Text("このアプリでは、個別の機能を提供するためにトラッキングを使用します。")
                .font(.headline)
                .multilineTextAlignment(.center)
            
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
            Text("トラッキングが拒否されました。")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Button("設定アプリを開く") {
                openSettings()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
    
    private func checkTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            isTrackingAuthorized = (status == .authorized)
            isCheckingTracking = false
        }
    }
    
    private func requestTrackingAuthorization() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                isTrackingAuthorized = (status == .authorized)
                showTrackingExplanation = false
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
