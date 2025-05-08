//
//  GroupRepositoryProtocol.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/09.
//

import Foundation


protocol FirestoreGroupRepositoryProtocol {
    func getGroup(groupCode: String, completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void)
    func createGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addUserToGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func createOrUpdateUser(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void)
    func checkUserExists(username: String, completion: @escaping (Bool, Error?) -> Void)
}
