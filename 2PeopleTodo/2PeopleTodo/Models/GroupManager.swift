//
//  GroupManager.swift
//  2PeopleTodo
//
//  Created by 櫻井絵理香 on 2024/08/23.
//

import Foundation
import FirebaseFirestore

class GroupManager {
    private let db = Firestore.firestore()

    func createOrJoinGroup(groupPassword: String, userId: String, completion: @escaping (Result<String, Error>) -> Void) {
        let groupId = hashGroupPassword(groupPassword)

        db.collection("groups").document(groupId).getDocument { (document, error) in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let document = document, document.exists {
                // グループが存在する場合、ユーザーを追加
                self.db.collection("groups").document(groupId).updateData([
                    "members": FieldValue.arrayUnion([userId])
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(groupId))
                    }
                }
            } else {
                // 新しいグループを作成
                self.db.collection("groups").document(groupId).setData([
                    "members": [userId],
                    "createdAt": Timestamp()
                ]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(groupId))
                    }
                }
            }
        }
    }

    private func hashGroupPassword(_ password: String) -> String {
        // 実際のアプリケーションでは、より安全なハッシュ関数を使用してください
        return password.data(using: .utf8)?.base64EncodedString() ?? ""
    }
}
