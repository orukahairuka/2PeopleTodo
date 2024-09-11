//
//  _PeopleTodoApp.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authManager = AuthManager.shared
    @State private var isLoading = true
    @State private var isTrackingDetermined = false
    @StateObject private var appState = AppState()  // AppState のインスタンスを作成


    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    LoadingView()
                } else if !isTrackingDetermined {
                    LoadingView()
                } else {
                    ContentView()
                        .environmentObject(authManager)
                        .environmentObject(appState)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // 2秒のローディング時間
                    self.isLoading = false
                    self.requestTracking()
                }
            }
        }
    }
    
    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { status in
            DispatchQueue.main.async {
                isTrackingDetermined = true
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.customImageColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                Image("mintodo") // アプリのロゴ画像を追加してください
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5)
            }
        }
    }
}

