//
//  _PeopleTodoApp.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseCore
import AppTrackingTransparency

@main
struct PeopleTodoApp: App {
    @State private var isLoading = true
    @State private var isTrackingDetermined = false

    @StateObject private var appViewModel = AppViewModel()

    init() {
        FirebaseApp.configure()
    }

    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async {
                isTrackingDetermined = true
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading || !isTrackingDetermined {
                    ProgressView("読み込み中...")
                } else {
                    ContentView(appViewModel: appViewModel)
                }
            }
            .onAppear {
                appViewModel.start()

                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isLoading = false
                    requestTracking()
                }
            }
        }
    }




}


