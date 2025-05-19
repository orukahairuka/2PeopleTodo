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

        // ✅ Repositoryのインスタンス（Group系は共通で使う）
        let groupRepository: GroupRepositoryProtocol = GroupRepository()

        // ✅ Firebase認証系のサービス
        let authService: AuthServiceProtocol = FirebaseAuthService()

        // ✅ UseCasesの構築
        let signInUseCase = SignInAnonymouslyUseCaseImpl(authService: authService)
        let joinOrCreateUseCase = JoinOrCreateGroupUseCaseImpl(
            authService: authService,
            repository: groupRepository
        )
        let checkUserUseCase = CheckUserExistsUseCaseImpl(repository: groupRepository)
        let createUserUseCase = CreateOrUpdateUserUseCaseImpl(repository: groupRepository)

        // ✅ 認証用 ViewModel の構築
        let authVM = AuthViewModel(
            signInUseCase: signInUseCase,
            joinOrCreateGroupUseCase: joinOrCreateUseCase,
            checkUserExistsUseCase: checkUserUseCase,
            createOrUpdateUserUseCase: createUserUseCase
        )


        self.authViewModel = authVM

        // 認証成功時の画面遷移をハンドル（Router的役割）
        self.authViewModel.onSuccess = { [weak self] groupCode, username, userId in
            let mainVM = MainViewModel(groupCode: groupCode, username: username, userId: userId)
            self?.currentScreen = .main(viewModel: mainVM)
        }


    }

    func start() {
        let status = trackingUseCase.getAuthorizationStatus()
        switch status {
        case .authorized:
            currentScreen = .auth
        case .denied, .restricted:
            currentScreen = .trackingDenied
        case .notDetermined:
            trackingUseCase.requestAuthorization { [weak self] _ in
                DispatchQueue.main.async {
                    self?.start() // 再判定
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

