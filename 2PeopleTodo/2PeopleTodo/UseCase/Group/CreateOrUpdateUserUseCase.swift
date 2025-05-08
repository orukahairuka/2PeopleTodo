//
//  CreateOrUpdateUserUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation

protocol CreateOrUpdateUserUseCase {
    func execute(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class CreateOrUpdateUserUseCaseImpl: CreateOrUpdateUserUseCase {
    private let repository: GroupRepositoryProtocol

    init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.createOrUpdateUser(userId: userId, username: username, groupCode: groupCode, completion: completion)
    }
}

