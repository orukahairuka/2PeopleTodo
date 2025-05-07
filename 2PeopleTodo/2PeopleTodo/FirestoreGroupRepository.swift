//
//  FirestoreGroupRepository.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import FirebaseFirestore

protocol FirestoreGroupRepositoryProtocol {
    func getGroup(groupCode: String, completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void)
    func createGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func addUserToGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void)
    func createOrUpdateUser(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void)
    func checkUserExists(username: String, completion: @escaping (Bool, Error?) -> Void)
}

final class FirestoreGroupRepository: FirestoreGroupRepositoryProtocol {
    private let db = Firestore.firestore()

    func getGroup(groupCode: String, completion: @escaping (Result<DocumentSnapshot?, Error>) -> Void) {
        let ref = db.collection("groups").document(groupCode)
        ref.getDocument { doc, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(doc))
            }
        }
    }

    func createGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("groups").document(groupCode)
        let data: [String: Any] = [
            "createdAt": FieldValue.serverTimestamp(),
            "members": [userId]
        ]
        ref.setData(data) { error in
            error == nil ? completion(.success(())) : completion(.failure(error!))
        }
    }

    func addUserToGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("groups").document(groupCode)
        ref.updateData([
            "members": FieldValue.arrayUnion([userId])
        ]) { error in
            error == nil ? completion(.success(())) : completion(.failure(error!))
        }
    }

    func createOrUpdateUser(userId: String, username: String, groupCode: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("users").document(userId)

        ref.getDocument { doc, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            var data: [String: Any] = [
                "username": username,
                "groupCode": groupCode,
                "lastUpdated": Timestamp()
            ]

            if doc?.exists == true {
                ref.updateData(data) { error in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
            } else {
                data["createdAt"] = Timestamp()
                ref.setData(data) { error in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
            }
        }
    }

    func checkUserExists(username: String, completion: @escaping (Bool, Error?) -> Void) {
        db.collection("users").whereField("username", isEqualTo: username).getDocuments { snap, error in
            if let error = error {
                completion(false, error)
            } else {
                completion(!(snap?.isEmpty ?? true), nil)
            }
        }
    }
}
