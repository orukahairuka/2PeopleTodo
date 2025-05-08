//
//  AuthViewModel.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/08.
//

import Foundation

final class AuthViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var groupCode: String = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String?


    private let joinOrCreateGroupUseCase: JoinOrCreateGroupUseCase
    private let signInUseCase: SignInAnonymouslyUseCase

    init(
        joinOrCreateGroupUseCase: JoinOrCreateGroupUseCase,
        signInUseCase: SignInAnonymouslyUseCase
    ) {
        self.joinOrCreateGroupUseCase = joinOrCreateGroupUseCase
        self.signInUseCase = signInUseCase
    }

    func signIn() {
        signInUseCase.execute { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func joinOrCreateGroup(isCreating: Bool) {
        joinOrCreateGroupUseCase.execute(groupCode: groupCode, username: username, isCreating: isCreating) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let code):
                    self?.groupCode = code
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

