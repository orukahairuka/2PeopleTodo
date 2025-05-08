//
//  CheckUserExistsUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation

protocol CheckUserExistsUseCase {
    func execute(username: String, completion: @escaping (Bool, Error?) -> Void)
}

final class CheckUserExistsUseCaseImpl: CheckUserExistsUseCase {
    private let repository: GroupRepositoryProtocol

    init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(username: String, completion: @escaping (Bool, Error?) -> Void) {
        repository.checkUserExists(username: username, completion: completion)
    }
}
