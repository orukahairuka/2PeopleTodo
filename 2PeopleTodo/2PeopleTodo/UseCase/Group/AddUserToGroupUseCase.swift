//
//  AddUserToGroupUseCase.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation



protocol AddUserToGroupUseCase {
    func execute(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void)
}

final class AddUserToGroupUseCaseImpl: AddUserToGroupUseCase {
    private let repository: GroupRepositoryProtocol

    init(repository: GroupRepositoryProtocol) {
        self.repository = repository
    }

    func execute(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        repository.addUserToGroup(groupCode: groupCode, userId: userId, completion: completion)
    }
}
