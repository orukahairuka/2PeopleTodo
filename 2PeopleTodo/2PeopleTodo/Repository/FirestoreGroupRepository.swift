//
//  FirestoreGroupRepository.swift
//  PeopleTodo
//
//  Created by 櫻井絵理香 on 2025/05/07.
//

import FirebaseFirestore


final class FirestoreGroupRepository: FirestoreGroupRepositoryProtocol {
    private let db = Firestore.firestore()

    //グループコードに対応するグループ情報を取得
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

    //新しいグループ作成し、作成者のユーザーIDをメンバーに登録
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

    //既存グループにユーザーを追加
    func addUserToGroup(groupCode: String, userId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let ref = db.collection("groups").document(groupCode)
        ref.updateData([
            "members": FieldValue.arrayUnion([userId])
        ]) { error in
            error == nil ? completion(.success(())) : completion(.failure(error!))
        }
    }

    //すでに存在する場合は更新、存在しなければ新規作成
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
                //ドキュメントが存在する
                ref.updateData(data) { error in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
            } else {
                //ドキュメントを新規作成
                data["createdAt"] = Timestamp()
                ref.setData(data) { error in
                    error == nil ? completion(.success(())) : completion(.failure(error!))
                }
            }
        }
    }

    //指定したユーザー名がすでに存在するかを確認
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
