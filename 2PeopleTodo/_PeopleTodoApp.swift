//
//  _PeopleTodoApp.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import SwiftUI
import FirebaseCore
import AppTrackingTransparency

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PeopleTodoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @State private var isLoading = true
    @State private var isTrackingDetermined = false

    // DI：ViewModelに UseCase を渡して初期化
    private let authService = FirebaseAuthService.shared
    private let repository = FirestoreGroupRepository()

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading || !isTrackingDetermined {
                } else {
                    let signInUseCase = SignInAnonymouslyUseCaseImpl(authService: authService)
                    let joinUseCase = JoinOrCreateGroupUseCaseImpl(authService: authService, repository: repository)
                    let viewModel = AuthViewModel(joinOrCreateGroupUseCase: joinUseCase, signInUseCase: signInUseCase)

                    AuthenticationView(viewModel: viewModel)
                        .environmentObject(viewModel)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isLoading = false
                    self.requestTracking()
                }
            }
        }
    }

    private func requestTracking() {
        ATTrackingManager.requestTrackingAuthorization { _ in
            DispatchQueue.main.async {
                isTrackingDetermined = true
            }
        }
    }
}
