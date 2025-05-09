//
//  GroupRepositoryMock.swift
//  PeopleTodoTests
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

//  MockGroupRepository.swift
//  PeopleTodoTests

import Foundation
import FirebaseFirestore
@testable import PeopleTodo

final class GroupRepositoryMock: GroupRepositoryProtocol {
    var getGroupResult: Result<DocumentSnapshot?, Error>?
    var createGroupResult: Result<Void, Error>?
    var addUserToGroupResult: Result<Void, Error>?
    var createOrUpdateUserResult: Result<Void, Error>?
    var checkUserExistsResult: (Bool, Error?)?

    func getGroup(groupCode: String, completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void) {
        if let result = getGroupResult {
            completion(result)
        }
    }

    func createGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = createGroupResult {
            completion(result)
        }
    }

    func addUserToGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = addUserToGroupResult {
            completion(result)
        }
    }

    func createOrUpdateUser(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        if let result = createOrUpdateUserResult {
            completion(result)
        }
    }

    func checkUserExists(username: String, completion: @escaping (Bool, Error?) -> Void) {
        if let result = checkUserExistsResult {
            completion(result.0, result.1)
        }
    }
}
