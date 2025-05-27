//
//  AppViewModel.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/19.
//

import SwiftUI

// アプリ全体の画面状態
enum AppScreen {
    case loading
    case trackingDenied
    case auth
    case main(viewModel: MainViewModel)
}

final class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .loading

    let authViewModel: AuthViewModel
    private let trackingUseCase: TrackingAuthorizationUseCaseProtocol

    init(
        trackingUseCase: TrackingAuthorizationUseCaseProtocol = TrackingAuthorizationUseCase()
    ) {
        self.trackingUseCase = trackingUseCase

        // Repository & Service
        let groupRepository: GroupRepositoryProtocol = GroupRepository()
        let authService: AuthServiceProtocol = FirebaseAuthService()

        // UseCases
        let signInUseCase = SignInAnonymouslyUseCaseImpl(authService: authService)
        let joinOrCreateUseCase = JoinOrCreateGroupUseCaseImpl(
            authService: authService,
            repository: groupRepository
        )
        let checkUserUseCase = CheckUserExistsUseCaseImpl(repository: groupRepository)
        let createUserUseCase = CreateOrUpdateUserUseCaseImpl(repository: groupRepository)

        // ViewModel
        self.authViewModel = AuthViewModel(
            signInUseCase: signInUseCase,
            joinOrCreateGroupUseCase: joinOrCreateUseCase,
            checkUserExistsUseCase: checkUserUseCase,
            createOrUpdateUserUseCase: createUserUseCase
        )
    }

    func start() {
        // ✅ onSuccess をここで設定（確実に表示前に設定される）
        self.authViewModel.onSuccess = { [weak self] groupCode, username, userId in
            print("✅ AppViewModel: onSuccess 受け取り → 遷移開始")

            let mainVM = MainViewModel(groupCode: groupCode, username: username, userId: userId)
            mainVM.onLogout = { [weak self] in
                self?.currentScreen = .auth
            }

            self?.currentScreen = .main(viewModel: mainVM)
        }

        // トラッキング許可状態に応じて遷移
        let status = trackingUseCase.getAuthorizationStatus()
        switch status {
        case .authorized:
            currentScreen = .auth
        case .denied, .restricted:
            currentScreen = .trackingDenied
        case .notDetermined:
            trackingUseCase.requestAuthorization { [weak self] _ in
                DispatchQueue.main.async {
                    self?.start() // 再評価
                }
            }
        @unknown default:
            currentScreen = .trackingDenied
        }
    }

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}
