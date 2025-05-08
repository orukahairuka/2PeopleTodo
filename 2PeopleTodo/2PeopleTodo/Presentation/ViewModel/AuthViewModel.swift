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


    private let signInUseCase: SignInAnonymouslyUseCase
    private let joinOrCreateGroupUseCase: JoinOrCreateGroupUseCase
    private let checkUserExistsUseCase: CheckUserExistsUseCase
    private let createOrUpdateUserUseCase: CreateOrUpdateUserUseCase

    init(
        signInUseCase: SignInAnonymouslyUseCase,
        joinOrCreateGroupUseCase: JoinOrCreateGroupUseCase,
        checkUserExistsUseCase: CheckUserExistsUseCase,
        createOrUpdateUserUseCase: CreateOrUpdateUserUseCase
    ) {
        self.signInUseCase = signInUseCase
        self.joinOrCreateGroupUseCase = joinOrCreateGroupUseCase
        self.checkUserExistsUseCase = checkUserExistsUseCase
        self.createOrUpdateUserUseCase = createOrUpdateUserUseCase
    }

    func signInAnonymously() {
        signInUseCase.execute { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func checkUsernameExists(completion: @escaping (Bool, Error?) -> Void) {
        checkUserExistsUseCase.execute(username: username, completion: completion)
    }

    func joinOrCreateGroup(isCreating: Bool, completion: @escaping (Bool) -> Void) {
        joinOrCreateGroupUseCase.execute(groupCode: groupCode, username: username, isCreating: isCreating) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    completion(true)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
}

