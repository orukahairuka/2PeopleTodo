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

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading {
                    LoadingView()
                } else if !isTrackingDetermined {
                    TrackingRequestView(isTrackingDetermined: $isTrackingDetermined)
                } else {
                    ContentView()
                        .environmentObject(authManager)
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

struct TrackingRequestView: View {
    @Binding var isTrackingDetermined: Bool
    
    var body: some View {
        VStack {
            Text("アプリを使用するには、トラッキングの許可が必要です")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Text("ユーザー識別のためにトラッキングを使用します。これにより、アプリ内でのあなたの情報を安全に管理できます。")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
            
            Button("トラッキングの設定") {
                ATTrackingManager.requestTrackingAuthorization { status in
                    DispatchQueue.main.async {
                        isTrackingDetermined = true
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}
