//
//  JoinOrCreateGroupUseCase.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/08.
//

import Foundation

protocol JoinOrCreateGroupUseCase {
    func execute(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void)
}

final class JoinOrCreateGroupUseCaseImpl: JoinOrCreateGroupUseCase {
    private let authService: AuthServiceProtocol
    private let repository: GroupRepositoryProtocol

    init(authService: AuthServiceProtocol, repository: GroupRepositoryProtocol) {
        self.authService = authService
        self.repository = repository
    }

    func execute(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let userId = authService.currentUser?.uid else {
            completion(.failure(NSError(domain: "JoinOrCreateGroup", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])))
            return
        }

        repository.getGroup(groupCode: groupCode) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let document):
                if let doc = document, doc.exists {
                    // 参加
                    self.repository.addUserToGroup(groupCode: groupCode, userId: userId) { result in
                        switch result {
                        case .success:
                            self.repository.createOrUpdateUser(userId: userId, username: username, groupCode: groupCode) { userResult in
                                userResult.map { _ in groupCode }.pipe(to: completion)
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                } else {
                    // 作成
                    self.repository.createGroup(groupCode: groupCode, userId: userId) { result in
                        switch result {
                        case .success:
                            self.repository.createOrUpdateUser(userId: userId, username: username, groupCode: groupCode) { userResult in
                                userResult.map { _ in groupCode }.pipe(to: completion)
                            }
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
}

extension Result {
    func pipe(to completion: @escaping (Result<Success, Failure>) -> Void) {
        completion(self)
    }
}
