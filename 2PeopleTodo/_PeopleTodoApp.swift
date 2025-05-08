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

    var body: some Scene {
        WindowGroup {
            Group {
                if isLoading || !isTrackingDetermined {
                    ProgressView("読み込み中...")
                } else {
                    let authService = FirebaseAuthService.shared
                    let repository = GroupRepository()

                    let signInUseCase = SignInAnonymouslyUseCaseImpl(authService: authService)
                    let joinGroupUseCase = JoinOrCreateGroupUseCaseImpl(authService: authService, repository: repository)
                    let checkUserExistsUseCase = CheckUserExistsUseCaseImpl(repository: repository)
                    let createOrUpdateUserUseCase = CreateOrUpdateUserUseCaseImpl(repository: repository)

                    let viewModel = AuthViewModel(
                        signInUseCase: signInUseCase,
                        joinOrCreateGroupUseCase: joinGroupUseCase,
                        checkUserExistsUseCase: checkUserExistsUseCase,
                        createOrUpdateUserUseCase: createOrUpdateUserUseCase
                    )

                    // ✅ View を返すようにする
                    AuthenticationView(viewModel: viewModel)
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
