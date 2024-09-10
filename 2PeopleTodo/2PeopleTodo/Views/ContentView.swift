//
//  ContentView.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import AppTrackingTransparency

struct ContentView: View {
    @StateObject private var appState = AppState()
    @StateObject private var todoListViewModel = TodoListViewModel()
    @State private var isTrackingAuthorized = false
    @State private var isCheckingTracking = true
    
    var body: some View {
        Group {
            if isCheckingTracking {
                ProgressView("トラッキング設定を確認中...")
            } else if !isTrackingAuthorized {
                TrackingConsentView(isAuthorized: $isTrackingAuthorized) {
                    // トラッキングが許可された後の処理
                    isTrackingAuthorized = true
                }
            } else {
                mainContent
            }
        }
        .onAppear(perform: checkTrackingAuthorization)
    }
    
    private var mainContent: some View {
        NavigationView {
            Group {
                if appState.isAuthenticated {
                    authenticatedView
                } else {
                    AuthenticationView()
                        .environmentObject(appState)
                }
            }
        }
        .background(Color.customImageColor.edgesIgnoringSafeArea(.all))
    }
    
    private var authenticatedView: some View {
        Group {
            if let groupCode = appState.groupCode, let username = appState.username {
                TabView {
                    TodoListView()
                        .environmentObject(appState)
                        .environmentObject(todoListViewModel)
                        .tabItem {
                            Label("タスク", systemImage: "list.bullet")
                        }
                    
                    CompletedTasksView(viewModel: todoListViewModel)
                        .environmentObject(appState)
                        .tabItem {
                            Label("完了済み", systemImage: "checkmark.circle")
                        }
                }
                .navigationBarItems(leading: Text("ユーザー: \(username)"), trailing: logoutButton)
                .onAppear {
                    todoListViewModel.fetchTasks(groupCode: groupCode)
                }
            } else {
                AuthenticationView()
                    .environmentObject(appState)
            }
        }
    }
    
    private var logoutButton: some View {
        Button("ログアウト") {
            appState.signOut()
        }
    }
    
    private func checkTrackingAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let status = ATTrackingManager.trackingAuthorizationStatus
            isTrackingAuthorized = (status == .authorized)
            isCheckingTracking = false
        }
    }
}

struct TrackingConsentView: View {
    @Binding var isAuthorized: Bool
    var onAuthorized: () -> Void
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var showSettingsButton = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("アプリを使用するには、トラッキングの許可が必要です")
                .font(.headline)
                .multilineTextAlignment(.center)
            
            Text("ユーザー識別のためにトラッキングを使用します。これにより、アプリ内でのあなたの情報を安全に管理できます。")
                .font(.body)
                .multilineTextAlignment(.center)
            
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                Button("トラッキングを許可する") {
                    requestTracking()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                Button("設定アプリを開く") {
                    openSettings()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("トラッキング状態"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onAppear {
            checkTrackingStatus()
        }
    }
    
    private func checkTrackingStatus() {
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            isAuthorized = true
            onAuthorized()
        case .denied, .restricted:
            showSettingsButton = true
            alertMessage = "トラッキングが拒否されています。アプリの機能を fully 使用するには、設定アプリからトラッキングを許可してください。"
            showingAlert = true
        case .notDetermined:
            showSettingsButton = false
        @unknown default:
            showSettingsButton = true
            alertMessage = "不明なエラーが発生しました。設定アプリからトラッキングの設定を確認してください。"
            showingAlert = true
        }
    }
    
    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    isAuthorized = true
                    onAuthorized()
                case .denied, .restricted:
                    showSettingsButton = true
                    alertMessage = "トラッキングが許可されませんでした。アプリの機能を fully 使用するには、設定アプリからトラッキングを許可してください。"
                    showingAlert = true
                case .notDetermined:
                    alertMessage = "トラッキングの許可状態が決定されていません。もう一度お試しください。"
                    showingAlert = true
                @unknown default:
                    showSettingsButton = true
                    alertMessage = "不明なエラーが発生しました。設定アプリからトラッキングの設定を確認してください。"
                    showingAlert = true
                }
            }
        }
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}
