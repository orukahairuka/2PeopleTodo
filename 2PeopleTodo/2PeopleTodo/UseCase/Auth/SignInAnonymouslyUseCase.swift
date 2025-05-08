//
//  SignInAnonymouslyUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/08.
//匿名認証

import Foundation
import FirebaseAuth

protocol SignInAnonymouslyUseCase {
    func execute(completion: @escaping (Result<User, Error>) -> Void)
}

final class SignInAnonymouslyUseCaseImpl: SignInAnonymouslyUseCase {
    private let authService: AuthServiceProtocol

    init(authService: AuthServiceProtocol) {
        self.authService = authService
    }

    func execute(completion: @escaping (Result<User, Error>) -> Void) {
        authService.signInAnonymously(completion: completion)
    }
}
