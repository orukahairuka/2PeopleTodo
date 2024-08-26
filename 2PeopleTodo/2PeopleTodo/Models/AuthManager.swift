//
//  AuthManager.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//
import SwiftUI
import FirebaseFirestore


class AuthManager {
    static let shared = AuthManager()
    private let db = Firestore.firestore()

    private init() {}

    func joinOrCreateGroup(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let groupRef = db.collection("groups").document(groupCode)

        groupRef.getDocument { [weak self] (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                // 既存のグループに参加
                self?.joinExistingGroup(groupRef: groupRef, username: username, completion: completion)
            } else {
                // 新しいグループを作成
                self?.createNewGroup(groupCode: groupCode, username: username, completion: completion)
            }
        }
    }


    private func checkUserExists(username: String, completion: @escaping (Bool) -> Void) {
        let userRef = db.collection("users").document(username)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    private func updateExistingUserGroup(username: String, groupCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let userRef = db.collection("users").document(username)
        userRef.updateData([
            "groupCode": groupCode,
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error updating user's group: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User's group successfully updated")
                self.addUserToGroup(username: username, groupCode: groupCode, completion: completion)
            }
        }
    }

    private func processNewUser(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let groupRef = db.collection("groups").document(groupCode)

        groupRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error getting document: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                // グループが存在する場合、参加処理を行う
                self?.joinExistingGroup(groupRef: groupRef, username: username, completion: completion)
            } else {
                // グループが存在しない場合、新規作成する
                self?.createNewGroup(groupCode: groupCode, username: username, completion: completion)
            }
        }
    }

    private func joinExistingGroup(groupRef: DocumentReference, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        groupRef.updateData([
            "members": FieldValue.arrayUnion([username])
        ]) { [weak self] err in
            if let err = err {
                print("Error updating group: \(err.localizedDescription)")
                completion(.failure(err))
            } else {
                print("User successfully added to group")
                self?.createUserDocument(username: username, groupCode: groupRef.documentID) { result in
                    switch result {
                    case .success:
                        completion(.success(groupRef.documentID))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func createNewGroup(groupCode: String, username: String, completion: @escaping (Result<String, Error>) -> Void) {
        let groupRef = db.collection("groups").document(groupCode)

        let newGroup = [
            "createdAt": FieldValue.serverTimestamp(),
            "members": [username]
        ] as [String : Any]

        groupRef.setData(newGroup) { [weak self] error in
            if let error = error {
                completion(.failure(error))
            } else {
                self?.createUserDocument(username: username, groupCode: groupCode) { result in
                    switch result {
                    case .success:
                        completion(.success(groupCode))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    private func createUserDocument(username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(username)

        userRef.setData([
            "groupCode": groupCode,
            "createdAt": Timestamp(),
            "lastUpdated": Timestamp()
        ]) { error in
            if let error = error {
                print("Error creating user document: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User document successfully created with group code")
                completion(.success(()))
            }
        }
    }

    private func addUserToGroup(username: String, groupCode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let groupRef = db.collection("groups").document(groupCode)
        groupRef.updateData([
            "members": FieldValue.arrayUnion([username])
        ]) { error in
            if let error = error {
                print("Error adding user to group: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("User successfully added to group")
                completion(.success(groupCode))
            }
        }
    }
}
